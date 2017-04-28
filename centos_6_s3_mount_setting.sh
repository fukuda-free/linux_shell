sudo yum update -y
sudo yum install golang fuse -y
export GOPATH=$HOME/go
go get github.com/kahing/goofys
go install github.com/kahing/goofys
S3_MOUNT_NAME='<マウントするディレクトリ>'
S3_BUCKET_NAME='<バケット名>'
mkdir ${S3_MOUNT_NAME}
${GOPATH}/bin/goofys ${S3_BUCKET_NAME} ${S3_MOUNT_NAME}
df -h