#/bin/bash
FILE_ENV="/home/.env"

export MINIO_ALIAS="demo_service_account"

touch ${FILE_ENV}

if ! grep -q "^S3_READ_ACCESS_ID=" ${FILE_ENV}; then
    mc alias set ${MINIO_ALIAS} http://minio:9000 ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY}

    output=$(mc admin accesskey create ${MINIO_ALIAS})

    echo S3_READ_ACCESS_ID=$(echo "$output" | grep "Access Key:" | awk '{print $3}') >> ${FILE_ENV}
    echo S3_READ_SECRET_KEY=$(echo "$output" | grep "Secret Key:" | awk '{print $3}') >> ${FILE_ENV}

    echo "Access Token for MinIO is created successfully"
else
    echo "Access Token for MinIO is created already"
fi
