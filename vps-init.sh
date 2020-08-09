#!/bin/bash

# example.com is updated to correct domain
DOMAIN="example.com";
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S");
REPORTS_FOLDER="/root/recon/reports/$TIMESTAMP";
GOLANG_DL="go1.14.6.linux-amd64.tar.gz";

export GO111MODULE=on;
export GOROOT=/usr/local/go;
export GOPATH=/root/go;
export GOBIN=$GOPATH/bin;
export GOCACHE=/root/.cache/go-build;

export HOME=/root;
export PATH=$PATH:$GOROOT/bin;
export PATH=$PATH:$GOBIN;

echo 'export GO111MODULE=on' >> /root/.bashrc;
echo 'export GOROOT=/usr/local/go' >> /root/.bashrc;
echo 'export GOPATH=/root/go' >> /root/.bashrc;
echo 'export GOBIN=$GOPATH/bin' >> /root/.bashrc;
echo 'export PATH=$PATH:$GOROOT/bin' >> /root/.bashrc;
echo 'export PATH=$PATH:$GOBIN' >> /root/.bashrc;

# install Go
cd /root;
curl -LO "https://golang.org/dl/$GOLANG_DL";
tar -C /usr/local/ -xzf $GOLANG_DL;
rm $GOLANG_DL;

# install cli packages
go get -u -v github.com/tomnomnom/httprobe;
go get -u -v github.com/projectdiscovery/httpx/cmd/httpx;
go get -u -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei;
go get -v github.com/projectdiscovery/subfinder/cmd/subfinder;
go get -v github.com/OWASP/Amass/v3/...;
go get -v github.com/ffuf/ffuf;
go get -v github.com/hakluke/hakrawler;

mkdir -p $REPORTS_FOLDER;

# nuclei install templates
nuclei -update-templates;

# subfinder
subfinder -d $DOMAIN -o "$REPORTS_FOLDER/subfinder.txt";

# amass 
amass enum -d $DOMAIN -o "$REPORTS_FOLDER/amass.txt";
amass enum -brute -d $DOMAIN -o "$REPORTS_FOLDER/amass-brute.txt";

# nuclei with the help of httpx
cat "$REPORTS_FOLDER/subfinder.txt" | httpx -silent | nuclei \
    -o "$REPORTS_FOLDER/nuclei-subfinder.txt" \
    -t basic-detections/ -t cves/ -t dns/ -t files/ -t panels/ \
    -t security-misconfiguration -t subdomain-takeover \
    -t technologies/ -t tokens/ -t vulnerabilities -t workflows;

cat "$REPORTS_FOLDER/amass.txt" | httpx -silent | nuclei \
    -o "$REPORTS_FOLDER/nuclei-amass.txt" \
    -t basic-detections/ -t cves/ -t dns/ -t files/ -t panels/ \ 
    -t security-misconfiguration -t subdomain-takeover \
    -t technologies/ -t tokens/ -t vulnerabilities -t workflows;

cat "$REPORTS_FOLDER/amass-brute.txt" | httpx -silent | nuclei \
    -o "$REPORTS_FOLDER/nuclei-brute.txt" \
    -t basic-detections/ -t cves/ -t dns/ -t files/ -t panels/ \
    -t security-misconfiguration -t subdomain-takeover \
    -t technologies/ -t tokens/ -t vulnerabilities -t workflows;

echo "Done!";

