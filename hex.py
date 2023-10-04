def file_to_hex(file_path):
    with open(file_path, 'rb') as file:
        hex_values = []
        count = 0
        for byte in file.read():
            hex_values.append(f'0x{byte:02X}')
            count += 1
            if count % 11 == 0:
                print(', '.join(hex_values) + ',')
                hex_values = []
        
        if hex_values:
            print(', '.join(hex_values) + ',')
        
        print(f"总共有 {count} 个十六进制数。")

if __name__ == "__main__":
    file_path = "block.html"  # 替换成你的文件路径
    file_to_hex(file_path)

