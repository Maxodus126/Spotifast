# Cara pakai spotifast (Windows)

## 1. Salin (tanpa setup.exe)
`spotifast` adalah **CLI tool** — satu file `spotifast.exe`, tidak ada installer wizard.

Salin folder ini, lalu jalankan dari terminal (CMD/PowerShell):

```powershell
# Buka terminal di folder spotifast-cli, lalu:
.\spotifast.exe -h
```

## 2. Instal ke PATH (agar bisa dipanggil dari mana saja)
Jalankan sebagai Administrator, atau biarkan skrip tanya:

```powershell
iwr -useb https://raw.githubusercontent.com/spotifast/cli/main/install.ps1 | iex
```

*(Repo GitHub masih belum ada — sementara gunakan `.\spotifast.exe` dari folder lokal.)*

## 3. Mulai modifikasi Spotify
Spotify harus **terdahulu terpasang** dari spotify.com.

```powershell
.\spotifast backup
.\spotifast apply
```

Spotify akan restart dan modifikasi aktif.

## 4. Uninstall
```powershell
.\uninstall.ps1
```

### Perintah cepat
| Perintah | Fungsi |
|----------|--------|
| `spotifast backup` | Cadangkan file Spotify |
| `spotifast apply` | Terapkan tema/ekstensi/custom app |
| `spotifast restore` | Kembalikan Spotify ke asli |
| `spotifast config` | Tampilkan/ubah pengaturan |
| `spotifast update` | Perbarui spotifast |
| `spotifast -h` | Bantuan lengkap |

---

**Perjanjian sebelum install** (wajib dibaca):
1. Fork dari Spicetify CLI (LGPL-2.1), tanpa garansi.
2. Memodifikasi file Spotify; update Spotify bisa merusak modifikasi.
3. Melanggar ToS Spotify — **risiko akun dibanned**.
4. **Tidak memblokir iklan**; iklan hilang hanya via Spotify Premium.
5. Digunakan sepenuhnya atas risiko milik sendiri.

Uninstall kapan saja: `.\uninstall.ps1`.
