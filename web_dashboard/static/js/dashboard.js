let monthlyRevenueChart = null;
let monthlyOrdersChart = null;
let productCategoryChart = null;
let paymentMethodChart = null;
let customerStateChart = null;
let reviewDeliveryChart = null;

function formatAngka(value) {
    if (value === null || value === undefined) return "-";
    return Number(value).toLocaleString("id-ID");
}

function formatMataUang(value) {
    if (value === null || value === undefined) return "-";

    return new Intl.NumberFormat("id-ID", {
        style: "currency",
        currency: "BRL",
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    }).format(Number(value));
}

function formatPersen(value) {
    if (value === null || value === undefined) return "-";
    return Number(value).toFixed(2) + "%";
}

function formatDesimal(value) {
    if (value === null || value === undefined) return "-";
    return Number(value).toFixed(2);
}

function namaBulanIndonesia(monthNumber) {
    const bulan = {
        1: "Januari",
        2: "Februari",
        3: "Maret",
        4: "April",
        5: "Mei",
        6: "Juni",
        7: "Juli",
        8: "Agustus",
        9: "September",
        10: "Oktober",
        11: "November",
        12: "Desember"
    };

    return bulan[monthNumber] || monthNumber;
}

function rapikanLabel(text) {
    if (!text) return "Tidak diketahui";

    return text
        .replaceAll("_", " ")
        .replace(/\b\w/g, char => char.toUpperCase());
}

function buatQueryFilter() {
    const year = document.getElementById("yearFilter").value;
    const month = document.getElementById("monthFilter").value;

    const params = new URLSearchParams();

    if (year) params.append("year", year);
    if (month) params.append("month", month);

    const queryString = params.toString();
    return queryString ? `?${queryString}` : "";
}

async function ambilData(url) {
    const response = await fetch(url);

    if (!response.ok) {
        throw new Error(`Gagal mengambil data dari ${url}`);
    }

    return response.json();
}

function hapusGrafik(chartInstance) {
    if (chartInstance) {
        chartInstance.destroy();
    }
}

async function muatOpsiFilter() {
    const data = await ambilData("/api/filter-options");

    const yearFilter = document.getElementById("yearFilter");
    const monthFilter = document.getElementById("monthFilter");

    data.years.forEach(year => {
        const option = document.createElement("option");
        option.value = year;
        option.textContent = year;
        yearFilter.appendChild(option);
    });

    data.months.forEach(month => {
        const option = document.createElement("option");
        option.value = month.month;
        option.textContent = namaBulanIndonesia(month.month);
        monthFilter.appendChild(option);
    });
}

async function muatKpi() {
    const filter = buatQueryFilter();
    const data = await ambilData(`/api/kpi${filter}`);

    document.getElementById("totalOrders").textContent = formatAngka(data.total_orders);
    document.getElementById("totalRevenue").textContent = formatMataUang(data.total_revenue);
    document.getElementById("averageOrderValue").textContent = formatMataUang(data.average_order_value);
    document.getElementById("averageDeliveryDays").textContent = formatDesimal(data.average_delivery_days);
    document.getElementById("lateDeliveryRate").textContent = formatPersen(data.late_delivery_rate_percent);
    document.getElementById("averageReviewScore").textContent = formatDesimal(data.average_review_score);
}

async function muatGrafikBulanan() {
    const filter = buatQueryFilter();
    const data = await ambilData(`/api/monthly-sales${filter}`);

    const labels = data.map(item => `${namaBulanIndonesia(item.month)} ${item.year}`);
    const revenue = data.map(item => Number(item.total_revenue));
    const orders = data.map(item => Number(item.total_orders));

    hapusGrafik(monthlyRevenueChart);
    hapusGrafik(monthlyOrdersChart);

    monthlyRevenueChart = new Chart(document.getElementById("monthlyRevenueChart"), {
        type: "line",
        data: {
            labels: labels,
            datasets: [{
                label: "Total Pendapatan",
                data: revenue,
                tension: 0.35,
                fill: false
            }]
        },
        options: {
            responsive: true,
            plugins: {
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return "Pendapatan: " + formatMataUang(context.raw);
                        }
                    }
                }
            },
            scales: {
                y: {
                    ticks: {
                        callback: function(value) {
                            return formatMataUang(value);
                        }
                    }
                }
            }
        }
    });

    monthlyOrdersChart = new Chart(document.getElementById("monthlyOrdersChart"), {
        type: "bar",
        data: {
            labels: labels,
            datasets: [{
                label: "Total Pesanan",
                data: orders
            }]
        },
        options: {
            responsive: true,
            plugins: {
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return "Pesanan: " + formatAngka(context.raw);
                        }
                    }
                }
            }
        }
    });
}

async function muatGrafikKategoriProduk() {
    const filter = buatQueryFilter();
    const data = await ambilData(`/api/product-categories${filter}`);

    const labels = data.map(item => rapikanLabel(item.product_category));
    const values = data.map(item => Number(item.total_product_sales));

    hapusGrafik(productCategoryChart);

    productCategoryChart = new Chart(document.getElementById("productCategoryChart"), {
        type: "bar",
        data: {
            labels: labels,
            datasets: [{
                label: "Total Penjualan Produk",
                data: values
            }]
        },
        options: {
            indexAxis: "y",
            responsive: true,
            plugins: {
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return "Penjualan: " + formatMataUang(context.raw);
                        }
                    }
                }
            },
            scales: {
                x: {
                    ticks: {
                        callback: function(value) {
                            return formatMataUang(value);
                        }
                    }
                }
            }
        }
    });
}

async function muatGrafikWilayahPelanggan() {
    const filter = buatQueryFilter();
    const data = await ambilData(`/api/customer-states${filter}`);

    const labels = data.map(item => item.customer_state);
    const values = data.map(item => Number(item.total_revenue));

    hapusGrafik(customerStateChart);

    customerStateChart = new Chart(document.getElementById("customerStateChart"), {
        type: "bar",
        data: {
            labels: labels,
            datasets: [{
                label: "Total Pendapatan",
                data: values
            }]
        },
        options: {
            responsive: true,
            plugins: {
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return "Pendapatan: " + formatMataUang(context.raw);
                        }
                    }
                }
            },
            scales: {
                y: {
                    ticks: {
                        callback: function(value) {
                            return formatMataUang(value);
                        }
                    }
                }
            }
        }
    });
}

async function muatGrafikMetodePembayaran() {
    const filter = buatQueryFilter();
    const data = await ambilData(`/api/payment-methods${filter}`);

    const labels = data.map(item => rapikanLabel(item.payment_type));
    const values = data.map(item => Number(item.total_payment_value));

    hapusGrafik(paymentMethodChart);

    paymentMethodChart = new Chart(document.getElementById("paymentMethodChart"), {
        type: "doughnut",
        data: {
            labels: labels,
            datasets: [{
                label: "Nilai Pembayaran",
                data: values
            }]
        },
        options: {
            responsive: true,
            plugins: {
                legend: {
                    position: "bottom"
                },
                tooltip: {
                    callbacks: {
                        label: function(context) {
                            return `${context.label}: ${formatMataUang(context.raw)}`;
                        }
                    }
                }
            }
        }
    });
}

async function muatGrafikUlasanPengiriman() {
    const filter = buatQueryFilter();
    const data = await ambilData(`/api/review-delivery${filter}`);

    const labels = data.map(item => item.delivery_status_group);
    const values = data.map(item => Number(item.average_review_score));

    hapusGrafik(reviewDeliveryChart);

    reviewDeliveryChart = new Chart(document.getElementById("reviewDeliveryChart"), {
        type: "bar",
        data: {
            labels: labels,
            datasets: [{
                label: "Rata-rata Skor Ulasan",
                data: values
            }]
        },
        options: {
            responsive: true,
            scales: {
                y: {
                    suggestedMin: 0,
                    suggestedMax: 5
                }
            }
        }
    });
}

async function muatTabelRisikoSeller() {
    const filter = buatQueryFilter();
    const data = await ambilData(`/api/seller-delivery-risk${filter}`);

    const tableBody = document.getElementById("sellerRiskTable");
    tableBody.innerHTML = "";

    if (data.length === 0) {
        const row = document.createElement("tr");
        row.innerHTML = `
            <td colspan="6">Tidak ada data seller yang memenuhi kriteria pada periode ini.</td>
        `;
        tableBody.appendChild(row);
        return;
    }

    data.forEach(item => {
        const row = document.createElement("tr");

        row.innerHTML = `
            <td>${item.seller_id}</td>
            <td>${item.seller_city}</td>
            <td>${item.seller_state}</td>
            <td>${formatAngka(item.total_items_sold)}</td>
            <td>${formatMataUang(item.total_product_sales)}</td>
            <td>${formatPersen(item.late_delivery_rate_percent)}</td>
        `;

        tableBody.appendChild(row);
    });
}

async function muatDashboard() {
    try {
        await muatKpi();
        await muatGrafikBulanan();
        await muatGrafikKategoriProduk();
        await muatGrafikWilayahPelanggan();
        await muatGrafikMetodePembayaran();
        await muatGrafikUlasanPengiriman();
        await muatTabelRisikoSeller();
    } catch (error) {
        console.error("Terjadi kesalahan saat memuat dashboard:", error);
        alert("Gagal memuat data dashboard. Pastikan Flask dan PostgreSQL berjalan dengan benar.");
    }
}

function pasangEventFilter() {
    document.getElementById("applyFilterButton").addEventListener("click", async () => {
        await muatDashboard();
    });

    document.getElementById("resetFilterButton").addEventListener("click", async () => {
        document.getElementById("yearFilter").value = "";
        document.getElementById("monthFilter").value = "";
        await muatDashboard();
    });
}

async function mulaiDashboard() {
    await muatOpsiFilter();
    pasangEventFilter();
    await muatDashboard();
}

mulaiDashboard();