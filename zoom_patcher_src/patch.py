image_base_address = 0x400000
#file_name = "Earth2160_SSE.exe"

patches = [
            {
                "comment": "disable change max zoom",
                "offset": 0x59b7e4,
                "old_values": [b'\x8b', b'\x50', b'\x18', b'\x89', b'\x15', b'\x60', b'\x75', b'\xa8', b'\x00'],
                "new_values": [b'\x90', b'\x90', b'\x90', b'\x90', b'\x90', b'\x90', b'\x90', b'\x90', b'\x90'] # 9 * NOP
            },
            {
                "comment": "disable change max zoom",
                "offset": 0x59c091,
                "old_values": [b'\x8b', b'\x48', b'\x18', b'\x89', b'\x0d', b'\x60', b'\x75', b'\xa8', b'\x00'],
                "new_values": [b'\x90', b'\x90', b'\x90', b'\x90', b'\x90', b'\x90', b'\x90', b'\x90', b'\x90'] # 9 * NOP
            },
            {
                "comment": "farplane",
                "offset": 0xAAC3B8,
                "old_values": [b'\x00', b'\x00', b'\x96', b'\x44'], # (float) 1200.0
                "new_values": [b'\x00', b'\x80', b'\x3b', b'\x45']  # (float) 3000.0
            },
            {
                "comment": "max_zoom",
                "offset": 0xA87560,
                "old_values": [b'\x00', b'\x00', b'\x70', b'\x42'], # (float) 60.0
                "new_values": [b'\x00', b'\x00', b'\xa0', b'\x42']  # (float) 80.0
            }
        ]

def to_hex(byte_arr):
    return "b'\\x" + ''.join(format(x, "02x") for x in byte_arr) + "'"

def patch_game(file_name):
    with open(file_name, "r+b") as file:
        for patch in patches:
            offset = patch["offset"] - image_base_address
            file.seek(offset)

            for i in range(0, len(patch["new_values"])):
                old_value = patch["old_values"][i]

                current_value = file.read(1)
                if old_value != current_value:
                    print(f"Error at patching {patch['comment']} at value index {i}")
                    print(f"Failed, expected value {to_hex(old_value)} but was {to_hex(current_value)}. Not patching -> exit")
                    exit(-1)


    with open(file_name, "r+b") as file:
        for patch in patches:
            offset = patch["offset"] - image_base_address

            file.seek(offset)
            for i in range(0, len(patch["new_values"])):
                file.write(patch["new_values"][i])
