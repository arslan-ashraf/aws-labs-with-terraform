

To force delete a secret in SecretsManager:
```
aws secretsmanager delete-secret \
    --secret-id <secret_name_or_ARN> \
    --force-delete-without-recovery
```