#!/usr/bin/env bash
set -euETo pipefail
shopt -s inherit_errexit

mach=$(uname -m)
if [[ ${mach} == "x86_64" ]]; then
    arch1="amd64"
    arch2="x64"
elif [[ ${mach} == "aarch64" ]]; then
    arch1="arm64"
    arch2="arm64"
else
    # Skip install on any arch other than amd64 and arm64
    exit 0
fi

# For 22.04, we need to get libssl1.1 and manually install
if [[ ${UBUNTU_VERSION} == "22.04" ]]; then
    if [[ ${mach} == "x86_64" ]]; then
        curl -sSfLo /tmp/libssl.deb http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.16_${arch1}.deb
    elif [[ ${mach} == "aarch64" ]]; then
        curl -sSfLo /tmp/libssl.deb http://launchpadlibrarian.net/475575244/libssl1.1_1.1.1f-1ubuntu2_${arch1}.deb
    fi
    apt-get install -y /tmp/libssl.deb
    rm -f /tmp/libssl.deb
fi

# Install live share prerequisites
curl -sSfLo /tmp/vsls-reqs https://aka.ms/vsls-linux-prereq-script
chmod +x /tmp/vsls-reqs
/tmp/vsls-reqs
rm -f /vsls-reqs

# Get the latest vscode server version
repo="microsoft/vscode"
latest_tag=$(curl -fsSL https://api.github.com/repos/${repo}/releases/latest | jq -r .tag_name)
tag_sha=$(curl -fsSL https://api.github.com/repos/${repo}/git/ref/tags/${latest_tag} | jq -r .object.sha)

# Download and install vscode server
echo "Installing code-server ${latest_tag} - ${tag_sha}"
curl -fsSLo /tmp/vscs.tgz "https://update.code.visualstudio.com/commit:${tag_sha}/server-linux-${arch2}/stable"
mkdir -p ~/.vscode-server/bin/"${tag_sha}"
pushd ~/.vscode-server/bin/"${tag_sha}"
tar xzf /tmp/vscs.tgz --no-same-owner --strip-components=1
rm -f /tmp/vscs.tgz

# Install extensions
export PATH=${PATH}:~/.vscode-server/bin/${tag_sha}/bin
set +e
finished=0
until [[ ${finished} == 1 ]]; do
    sleep 5
    #code-server --install-extension ms-vsliveshare.vsliveshare
    code-server --install-extension cseelye.vscode-allofthem
    code-server --install-extension ms-python.python
    code-server --install-extension iliazeus.vscode-ansi
    code-server --install-extension eriklynd.json-tools
    code-server --install-extension hangxingliu.vscode-systemd-support
    finished=1
done
