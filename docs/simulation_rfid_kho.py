"""
Mô phỏng đơn giản hệ RFID trong kho: lưu lượng slotted ALOHA,
xác suất đọc thành công theo số thẻ, thời gian quét tồn kho.

Chạy:  python simulation_rfid_kho.py
Yêu cầu: pip install numpy matplotlib
"""

from __future__ import annotations

import os

import matplotlib.pyplot as plt
import numpy as np

# Thư mục lưu hình (cùng cấp với script)
OUT_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "figures")
os.makedirs(OUT_DIR, exist_ok=True)

# Ngôn ngữ hiển thị (tránh lỗi font trên một số máy Windows)
plt.rcParams["font.family"] = "DejaVu Sans"


def plot_throughput_aloha() -> str:
    """Đồ thị lý thuyết: throughput S theo offered load G (slotted ALOHA)."""
    g = np.linspace(0.01, 4.0, 400)
    s = g * np.exp(-g)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(g, s, "b-", linewidth=2, label=r"$S = G e^{-G}$")
    ax.axvline(1.0, color="gray", linestyle="--", alpha=0.8, label=r"$G = 1$ (tối ưu)")
    ax.scatter([1.0], [np.exp(-1)], color="red", s=80, zorder=5, label=r"$S_{\max} = 1/e$")
    ax.set_xlabel("Offered load G (số gói/slot trung bình)")
    ax.set_ylabel("Throughput S (thành công/slot)")
    ax.set_title("Slotted ALOHA — throughput theo offered load")
    ax.grid(True, alpha=0.3)
    ax.legend()
    fig.tight_layout()
    path = os.path.join(OUT_DIR, "hinh1_throughput_aloha.png")
    fig.savefig(path, dpi=150)
    plt.close(fig)
    return path


def simulate_read_success(
    n_tags: int,
    n_slots: int,
    trials: int = 5000,
    seed: int = 42,
) -> float:
    """
    Mỗi thẻ chọn ngẫu nhiên một slot trong khung n_slots.
    Thẻ được tính đọc thành công trong một lần thử nếu slot đó chỉ có đúng một thẻ.
    Trả về xác suất trung bình / thẻ / lần thử.
    """
    rng = np.random.default_rng(seed)
    total_tag_success = 0
    for _ in range(trials):
        slots_chosen = rng.integers(0, n_slots, size=n_tags)
        counts = np.bincount(slots_chosen, minlength=n_slots)
        for s in slots_chosen:
            if counts[s] == 1:
                total_tag_success += 1
    return total_tag_success / (trials * max(n_tags, 1))


def plot_success_vs_tags() -> str:
    """Tỉ lệ thẻ đọc được (trung bình) theo số thẻ trong khung cố định."""
    n_slots = 128
    tags_range = np.arange(5, 121, 5)
    rates = [simulate_read_success(int(n), n_slots) for n in tags_range]

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(tags_range, rates, "o-", color="darkgreen", linewidth=1.5, markersize=5)
    ax.set_xlabel("Số thẻ trong vùng đọc")
    ax.set_ylabel("Tỉ lệ thẻ đọc thành công (trung bình / thẻ / lần thử)")
    ax.set_title(f"Mô phỏng đơn giản — khung {n_slots} slot, va chẫm ngẫu nhiên")
    ax.grid(True, alpha=0.3)
    fig.tight_layout()
    path = os.path.join(OUT_DIR, "hinh2_success_vs_tags.png")
    fig.savefig(path, dpi=150)
    plt.close(fig)
    return path


def plot_inventory_time() -> str:
    """Thời gian quét ước lượng khi tăng số thẻ (mô hình lũy thừa đơn giản)."""
    n_items = np.array([100, 500, 1000, 2000, 5000, 10000])
    # Giả sử mỗi vòng đọc xử lý tối đa ~80 thẻ hiệu quả; số vòng tăng gần tuyến tính
    rounds = np.ceil(n_items / 80.0)
    time_sec = rounds * 0.25  # 0.25s mỗi vòng (ví dụ)

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.bar(range(len(n_items)), time_sec, color="steelblue", edgecolor="navy", alpha=0.85)
    ax.set_xticks(range(len(n_items)))
    ax.set_xticklabels([str(x) for x in n_items])
    ax.set_xlabel("Tổng số thẻ cần quét (tồn kho)")
    ax.set_ylabel("Thời gian ước lượng (giây)")
    ax.set_title("Thời gian quét tồn kho (mô hình minh họa)")
    ax.grid(True, axis="y", alpha=0.3)
    fig.tight_layout()
    path = os.path.join(OUT_DIR, "hinh3_inventory_time.png")
    fig.savefig(path, dpi=150)
    plt.close(fig)
    return path


def main() -> None:
    p1 = plot_throughput_aloha()
    p2 = plot_success_vs_tags()
    p3 = plot_inventory_time()
    print("Saved:")
    for p in (p1, p2, p3):
        print(" ", p)


if __name__ == "__main__":
    main()
