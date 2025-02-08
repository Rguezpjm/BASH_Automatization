import hashlib

def calcular_hash(archivo, algoritmo):
    hash_func = hashlib.new(algoritmo)
    with open(archivo, 'rb') as f:
        while chunk := f.read(4096):
            hash_func.update(chunk)
    return hash_func.hexdigest()

def mostrar_hashes(archivo):
    algoritmos = ['md5', 'sha1', 'sha256', 'sha512']
    print(f"Hashes del archivo '{archivo}':")
    for algoritmo in algoritmos:
        print(f"{algoritmo.upper()}: {calcular_hash(archivo, algoritmo)}")

def verificar_integridad(archivo, hash_esperado, algoritmo='sha256'):
    hash_calculado = calcular_hash(archivo, algoritmo)
    if hash_calculado == hash_esperado:
        print("La integridad del archivo está verificada.")
    else:
        print("ALERTA: El archivo ha sido modificado o está corrupto.")
        print(f"Hash esperado: {hash_esperado}")
        print(f"Hash calculado: {hash_calculado}")

# Ejemplo de uso
if __name__ == "__main__":
    archivo_a_verificar = input("Ingrese la ruta del archivo a verificar: ").strip().strip('"')
    mostrar_hashes(archivo_a_verificar)
    hash_esperado = input("Ingrese el hash esperado: ").strip()
    algoritmo = input("Ingrese el algoritmo de hash (md5, sha1, sha256, sha512): ").strip()
    verificar_integridad(archivo_a_verificar, hash_esperado, algoritmo)
