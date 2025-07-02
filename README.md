# SG-SRF: Scribble-Guided Structural Regression Fusion for Multimodal Change Detection

This is the official MATLAB implementation of our IEEE GRSL paper:

> **Scribble-Guided Structural Regression Fusion for Multimodal Remote Sensing Change Detection**  
> Yongjie Zheng, Sicong Liu, Lorenzo Bruzzone  
> Accepted in IEEE Geoscience and Remote Sensing Letters (GRSL), 2025

[[📰 Paper (GRSL)]([https://ieeexplore.ieee.org/](https://doi.org/10.1109/LGRS.2025.3575620))]  
[[📂 Project Page](https://github.com/MissYongjie/SG-SRF)]  
[[📌 Dataset Download (Baidu Cloud)](https://pan.baidu.com/s/1zpL5K_E30D3U1iB9xKo13A?pwd=8ivt)]  
🔑 Extraction Code: `8ivt`

---

## 🌟 Highlights

- ✔️ Weakly-supervised change detection using sparse scribbles
- ✔️ Works for both multimodal (SAR-Optical) and homogeneous image pairs
- ✔️ Combines hypergraph-based structure modeling with scribble guidance
- ✔️ Outperforms prior unsupervised/weakly-supervised CD methods

---

## 📁 Project Structure

```text
SG-SRF-main/
├── SG_SRF_demo.m                        # Main experiment script (full pipeline)
├── Abs_scribbles_SG_SRF_demo.m         # Ablation study: different scribble sparsity
├── Abs_superpixels_SG_SRF_demo.m       # Ablation study: different superpixel counts
├── auxi_funcs/                          # All utility functions (regression, Laplacian, metrics, etc.)
├── GC/                                  # Graph-cut / MRF-related modules
├── GMMMSP-superpixel-master/           # GMM superpixel code (for segmentation)
├── datasets/                            # Example dataset(s) (Dataset#1 included)
├── LICENSE                              # MIT License
└── README.md                            # Project description
