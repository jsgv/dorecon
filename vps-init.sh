#!/bin/bash

DOMAINS=(PLACEHOLDER_DOMAINS);
DORECON=0;

TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S");
REPORTS_FOLDER="/root/recon/reports/$TIMESTAMP";
GOLANG_DL="go1.15.linux-amd64.tar.gz";

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

# install tools
go get -u -v github.com/tomnomnom/httprobe;
go get -u -v github.com/projectdiscovery/httpx/cmd/httpx;
go get -u -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei;
go get -v github.com/projectdiscovery/subfinder/cmd/subfinder;
go get -v github.com/OWASP/Amass/v3/...;
go get -v github.com/ffuf/ffuf;
go get -v github.com/hakluke/hakrawler;

# nuclei install templates
nuclei -update-templates;

mkdir -p $REPORTS_FOLDER;

for domain in "${DOMAINS[@]}"
do
    OUT_FOLDER="$REPORTS_FOLDER/$domain"
    mkdir -p "$OUT_FOLDER";

    if [[ "$DORECON" -eq 1 ]];
    then
        subfinder -d $domain -o "$OUT_FOLDER/subfinder.txt";
        sort -u -o "$OUT_FOLDER/subfinder.txt" "$OUT_FOLDER/subfinder.txt"

        amass enum -brute -d $domain -o "$OUT_FOLDER/amass.txt";
        sort -u -o "$OUT_FOLDER/amass.txt" "$OUT_FOLDER/amass.txt"

        cat "$OUT_FOLDER/subfinder.txt" \
                "$OUT_FOLDER/amass.txt" | \
            sort -u | \
            httpx -silent | \
            nuclei -silent \
                -c 100 -retries 3 -pbar \
                -o "$OUT_FOLDER/nuclei.txt" \
                -t basic-detections/ -t cves/ -t dns/ -t files/ -t panels/ \
                -t security-misconfiguration -t subdomain-takeover \
                -t technologies/ -t tokens/ -t vulnerabilities/ -t workflows/ ;
    fi
done

echo "All done!";

