import os
import xml.etree.ElementTree as ET

def extract_urls_from_sitemap(sitemap_file_path):
    """
    Mengekstrak semua URL dari file sitemap XML.

    Args:
        sitemap_file_path (str): Path lengkap ke file sitemap.xml Anda.

    Returns:
        list: Daftar string URL yang ditemukan dalam sitemap.
    """
    urls = []
    try:
        tree = ET.parse(sitemap_file_path)
        root = tree.getroot()

        # Namespace yang umum digunakan dalam sitemap
        namespaces = {'sitemap': 'http://www.sitemaps.org/schemas/sitemap/0.9'}

        # Mencari semua elemen 'url' dan kemudian elemen 'loc' di dalamnya
        for url_element in root.findall('sitemap:url', namespaces):
            loc_element = url_element.find('sitemap:loc', namespaces)
            if loc_element is not None:
                urls.append(loc_element.text)
        
        # Penanganan jika ini adalah sitemap index file
        if not urls: 
            for sitemap_element in root.findall('sitemap:sitemap', namespaces):
                loc_element = sitemap_element.find('sitemap:loc', namespaces)
                if loc_element is not None:
                    print(f"Ditemukan sitemap lain di: {loc_element.text}. Anda perlu mengunduh dan memprosesnya juga.")

    except FileNotFoundError:
        print(f"Error: File '{sitemap_file_path}' tidak ditemukan.")
    except ET.ParseError:
        print(f"Error: Gagal mem-parsing file XML. Pastikan '{sitemap_file_path}' adalah file XML yang valid.")
    except Exception as e:
        print(f"Terjadi kesalahan: {e}")
        
    return urls

def save_urls_to_file(urls_list, output_file_path, file_format='py'):
    """
    Menyimpan daftar URL ke dalam file.

    Args:
        urls_list (list): Daftar URL yang akan disimpan.
        output_file_path (str): Path lengkap untuk file output.
        file_format (str): Format output. 'py' untuk file Python, 'txt' untuk file teks biasa.
    """
    try:
        with open(output_file_path, 'w', encoding='utf-8') as f:
            if file_format == 'py':
                # Menyimpan sebagai variabel Python (list of strings)
                f.write("test_urls = [\n")
                for url in urls_list:
                    f.write(f"    '{url}',\n")
                f.write("]\n")
                print(f"URL berhasil disimpan ke '{output_file_path}' sebagai variabel Python.")
            elif file_format == 'txt':
                # Menyimpan sebagai daftar baris teks biasa
                for url in urls_list:
                    f.write(f"{url}\n")
                print(f"URL berhasil disimpan ke '{output_file_path}' sebagai teks biasa.")
            else:
                print("Format file tidak didukung. Harap pilih 'py' atau 'txt'.")
    except Exception as e:
        print(f"Error saat menyimpan file: {e}")

# --- CARA MENGGUNAKAN SKRIP INI ---
if __name__ == "__main__":
    # Mendapatkan direktori kerja saat ini
    current_directory = os.getcwd() 
    
    # Konfigurasi input sitemap file
    sitemap_filename = 'sitemap.xml' # Nama file sitemap Anda yang sudah di-download
    sitemap_path = os.path.join(current_directory, sitemap_filename)
    
    # Konfigurasi output file
    output_filename = 'testdata.py' # Nama file output Anda, bisa diganti jadi 'urls.txt' atau lainnya
    output_file_path = os.path.join(current_directory, output_filename)
    output_file_format = 'py' # Ganti 'txt' jika ingin disimpan sebagai teks biasa per baris

    print(f"Mencoba mencari sitemap di: {sitemap_path}")

    extracted_urls = extract_urls_from_sitemap(sitemap_path)
    
    if extracted_urls:
        print(f"\nBerhasil mengekstrak {len(extracted_urls)} URL dari '{sitemap_path}'.")
        save_urls_to_file(extracted_urls, output_file_path, output_file_format)
        
        if output_file_format == 'py':
            print(f"\nUntuk menggunakan URL ini di skrip Python lain, Anda bisa import seperti ini:")
            print(f"   from {output_filename.replace('.py', '')} import test_urls")
            print(f"   print(test_urls[0]) # Akan mencetak URL pertama")
    else:
        print("\nTidak ada URL yang diekstrak. Mohon periksa kembali file sitemap Anda atau path-nya.")