#file-name: dockerfile
FROM mongo:4.2

# Run the Update
RUN apt-get update && apt-get upgrade -y

# Install pre-reqs
# RUN apt-get install -y s3cmd
RUN apt-get install -y zip

# Create directories
RUN mkdir -p /home/ubuntu/backups
RUN mkdir -p /home/ubuntu/dump

# Copy sh script
COPY backup.sh /home/ubuntu
# COPY .s3cfg /root

CMD tail -f /dev/null