# sdfgen

```bash
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt-get install -y nodejs

sudo apt-get install libx11-dev libxinerama-dev libasound2-dev

git clone --recursive https://github.com/VladislavZavadskyy/sdfgen
cd sdfgen

sudo ln -s /usr/include/locale.h /usr/include/xlocale.h

node Kha/make krom --shaderversion 450
node Kha/make --compile --shaderversion 450

cd build/krom && ../linux/sdfgen
```

## Convert output to numpy.ndarray
```python
import struct
import numpy as np

with open('./build/krom/out.bin', 'rb') as f:
    data = f.read()
numel = len(data) / 4.
assert numel.is_integer()
numel = int(numel)
sdf = struct.unpack('f'*numel, data)
sdf = np.array(sdf).reshape(150, 150, 150)  # shape may vary
```

## Plot
```python

from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
%matplotlib notebook  # if you are inside jupyter

xs = np.arange(sdf.shape[0])[:, None, None].repeat(sdf.shape[1], 1).repeat(sdf.shape[2], 2)
ys = np.arange(sdf.shape[1])[None, :, None].repeat(sdf.shape[0], 0).repeat(sdf.shape[2], 2)
zs = np.arange(sdf.shape[2])[None, None, :].repeat(sdf.shape[1], 1).repeat(sdf.shape[0], 0)
coords = np.stack([xs, ys, zs], -1)

fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')

ax.set_xlim(coords[..., 0].min(), coords[..., 0].max())
ax.set_ylim(coords[..., 1].min(), coords[..., 1].max())
ax.set_zlim(coords[..., 2].min(), coords[..., 2].max())

coords = coords.reshape(-1, 3)
sdf = sdf.reshape(-1)

indices = sdf < 0  # choose which points to display here
coords = coords[indices]
sdf = sdf[indices]

# optional samplitng, for smaller latency
indices = np.random.choice(len(coords), 10000, False)
coords = coords[indices]
sdf = sdf[indices]

axx = ax.scatter(coords[:, 0], coords[:, 1], coords[:, 2], s=1, c=sdf, cmap=plt.get_cmap('viridis'))
plt.colorbar(axx)
plt.show();

```
