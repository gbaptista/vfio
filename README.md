# vfio

A command-line interface to help you set up [VFIO](https://www.kernel.org/doc/html/latest/driver-api/vfio.html) on [IOMMU](https://en.wikipedia.org/wiki/Input%E2%80%93output_memory_management_unit) compatible hardware for a seamless Virtual Machine experience.

- [Usage](#usage)
- [Installing](#installing)
  - [Requirements](#requirements)
- [Development](#development)
- [References](#references)

## Usage
```bash
vfio
vfio [id]
vfio [id] [attribute] [value]
vfio [id] passthrough true
vfio grub
vfio config
vfio help
```
## Installing

```bash
git clone https://github.com/gbaptista/vfio.git vfio-source

cd vfio-source

fnx run/install.fnl

cd ~

vfio
```

### Requirements

- [fnx](https://github.com/gbaptista/fnx) `0.1.3` or later.
- [Unix](https://en.wikipedia.org/wiki/Unix)
  - [`lspci`](https://en.wikipedia.org/wiki/Lspci)

## Development

```
fnx dep install
fnx run/test.fnl
```

## References

- [PCI passthrough via OVMF](https://wiki.archlinux.org/title/PCI_passthrough_via_OVMF)
- [VFIO](https://www.kernel.org/doc/html/latest/driver-api/vfio.html)
- [IOMMU](https://en.wikipedia.org/wiki/Input%E2%80%93output_memory_management_unit)
- [VFIO - How I game on Linux](https://b1nzy.com/blog/vfio.html)
- [Evdev Passthrough Explained — Cheap, Seamless VM Input](https://passthroughpo.st/using-evdev-passthrough-seamless-vm-input/)
- [Beginner VFIO Tutorial](https://www.youtube.com/watch?v=fFz44XivxWI)
