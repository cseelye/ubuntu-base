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


#
# Live Share prerequisites
#
echo "* * *  Installing Live Share prerequisites"
# For 22.04, we need to get libssl1.1 and manually install before the vsls script
if [[ ${UBUNTU_VERSION} == "22.04" ]]; then
    if [[ ${mach} == "x86_64" ]]; then
        curl -sSfLo /tmp/libssl.deb http://security.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.1f-1ubuntu2.16_${arch1}.deb
    elif [[ ${mach} == "aarch64" ]]; then
        curl -sSfLo /tmp/libssl.deb http://launchpadlibrarian.net/475575244/libssl1.1_1.1.1f-1ubuntu2_${arch1}.deb
    fi
    apt-get install -y /tmp/libssl.deb
    rm -f /tmp/libssl.deb
fi

# Install live share prerequisites from official script
curl -sSfLo /tmp/vsls-reqs https://aka.ms/vsls-linux-prereq-script
chmod +x /tmp/vsls-reqs
/tmp/vsls-reqs
rm -f /vsls-reqs


#
# VS Code Server
#
echo "* * *  Installing VS Code Server"
# Get the most recent version tags from the vscode repo
repo="microsoft/vscode"
version_count=3 # Get the most recent 3 versions
all_tags=$(git ls-remote --tags https://github.com/${repo}.git | grep 'refs/tags/[0-9]')
recent_tags=($(echo "${all_tags}" | sed 's|.*/||' | grep -v '\^' | sort -rV | head -n${version_count}))
newest_ver=""
for tag_ver in "${recent_tags[@]}"; do
    # Account for both lightweight and annotated tags
    lines=$(echo "${all_tags}" | grep "${tag_ver}")
    if [[ $(echo "${lines}" | wc -l) -eq 1 ]]; then
        tag_sha=$(echo "${lines}" | awk '{print $1}')
    else
        tag_sha=$(echo "${lines}" | grep "${tag_ver}\^{}" | awk '{print $1}')
    fi
    if [[ -z ${newest_ver} ]]; then
        newest_ver=${tag_sha}
    fi
    echo "Installing code-server ${tag_ver} - ${tag_sha}"
    curl -fsSLo /tmp/vscs.tgz "https://update.code.visualstudio.com/commit:${tag_sha}/server-linux-${arch2}/stable"
    mkdir -p ~/.vscode-server/bin/"${tag_sha}"
    pushd ~/.vscode-server/bin/"${tag_sha}" >/dev/null
    tar xzf /tmp/vscs.tgz --no-same-owner --strip-components=1
    popd >/dev/null
    rm -f /tmp/vscs.tgz
done
echo "newest_ver=${newest_ver}"


#
# VS Code extensions
#
echo "* * *  Installing VS Code Extensions"
extensions=(
    cseelye.vscode-allofthem
    ms-python.python
    ms-python.vscode-pylance
    iliazeus.vscode-ansi
    eriklynd.json-tools
    hangxingliu.vscode-systemd-support
    redhat.vscode-yaml
    ms-vsliveshare.vsliveshare
)

export PATH=${PATH}:~/.vscode-server/bin/${newest_ver}/bin
for extname in "${extensions[@]}"; do
    code-server --install-extension ${extname}
done
