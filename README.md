# sdfgen

```bash
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo apt-get install libx11-dev libxinerama-dev libasound2-dev

git clone --recursive https://github.com/VladislavZavadskyy/sdfgen
cd sdfgen

node Kha/make krom --shaderversion 450
node Kha/make --compile --shaderversion 450

```
