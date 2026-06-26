from botocore.signers import CloudFrontSigner
import rsa
import time
import json

def rsa_signer(message):
	with open("private_key_for_cloudfront.pem", "rb") as f:
		key = rsa.PrivateKey.load_pkcs1(f.read())
	return rsa.sign(message, key, "SHA-1")

signer = CloudFrontSigner(
	key_id="<public_key_id>",
	rsa_signer=rsa_signer
)

# get seconds since epoch as an integer
expiration_epoch = int(time.time())
print(expiration_epoch) 			# example: 178233859

resource_url = "<cloudfront_url>/<page>"
ipv4_address = "<ipv4_address>/32"
ipv6_address = "<ipv6_address>/128"

policy = json.dumps({
    "Statement": [
        {
            "Resource": resource_url,
            "Condition": {
                "DateLessThan": {
                    "AWS:EpochTime": expiration_epoch + 180
                },
                "IpAddress": {
                    "AWS:SourceIp": ipv6_address
                }
            }
        }
    ]
})

url = signer.generate_presigned_url(
	resource_url,
	policy=policy
)

print(url)