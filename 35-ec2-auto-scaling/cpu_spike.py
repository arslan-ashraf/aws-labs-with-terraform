import math
import hashlib
import os
import time


def compute_slow_hash(password: str, salt: bytes, iterations: int = 500000) -> bytes:
    """
    Computes a slow, CPU-intensive cryptographic hash using PBKDF2.
    """
    # pbkdf2_hmac forces the CPU to loop the hashing process 'iterations' times
    hashed_password = hashlib.pbkdf2_hmac(
        hash_name='sha256',
        password=password.encode('utf-8'),
        salt=salt,
        iterations=iterations
    )
    return hashed_password


def cpu_spike():
    x = 0
    count = 0

    user_password = "SuperSecurePassword123"
    
    # time how long the CPU takes to compute the hash
    print(f"Computing hash with 500,000 iterations...")
    start_time = time.perf_counter()

    while True:
        x += math.sqrt(12345.6789)
        x %= 1000000
        x += abs(math.sin(x))

        # generate a random 16-byte salt to prevent rainbow table attacks
        user_salt = os.urandom(16)
        
        key = compute_slow_hash(user_password, user_salt, iterations=500000)
    
        end_time = time.perf_counter()
        execution_time = end_time - start_time
        

        if count % 100 == 0:
            print("still going!!!")

            print(f"Hash computed successfully!")
            print(f"Time taken: {execution_time:.4f} seconds")
            print(f"Resulting Key (hex): {key.hex()[:32]}...")
            
        count += 1



if __name__ == "__main__":

    cpu_spike()