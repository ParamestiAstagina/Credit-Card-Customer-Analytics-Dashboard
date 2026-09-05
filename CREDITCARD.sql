create database credit_card;
use credit_card;

-- DATA QUALITY CHECK
-- Mengecek data duplikat berdasarkan customer dan periode transaksi mingguan
SELECT
    client_num,
    week_start_date,
    COUNT(*) AS jumlah
FROM creditcard
GROUP BY client_num, week_start_date
HAVING COUNT(*) > 1;

-- Mengecek missing value
SELECT
    SUM(CASE WHEN credit_limit IS NULL THEN 1 ELSE 0 END) AS null_credit_limit,
    SUM(CASE WHEN avg_utilization_ratio IS NULL THEN 1 ELSE 0 END) AS null_utilization,
    SUM(CASE WHEN total_trans_amt IS NULL THEN 1 ELSE 0 END) AS null_trans_amt,
    SUM(CASE WHEN total_trans_vol IS NULL THEN 1 ELSE 0 END) AS null_trans_vol,
    SUM(CASE WHEN interest_earned IS NULL THEN 1 ELSE 0 END) AS null_interest,
    SUM(CASE WHEN delinquent_acc IS NULL THEN 1 ELSE 0 END) AS null_delinquent
FROM creditcard;

-- Mengecek nilai yang tidak valid
SELECT *
FROM creditcard
WHERE credit_limit < 0
   OR total_trans_amt < 0
   OR total_trans_vol < 0
   OR avg_utilization_ratio < 0
   OR avg_utilization_ratio > 1;
   
-- CUSTOMER SEGMENTATION
-- Mengelompokkan customer berdasarkan tingkat penggunaan limit kredit:
   SELECT
    client_num,
    credit_limit,
    avg_utilization_ratio,

    CASE
        WHEN avg_utilization_ratio < 0.30 THEN 'Low'
        WHEN avg_utilization_ratio < 0.70 THEN 'Medium'
        ELSE 'High'
    END AS utilization_category

FROM creditcard;

-- OVERALL BUSINESS PERFORMANCE
-- Menghitung KPI utama

SELECT
    COUNT(DISTINCT client_num) AS total_customer,
    AVG(credit_limit) AS avg_credit_limit,
    AVG(avg_utilization_ratio) AS avg_utilization,
    SUM(total_trans_amt) AS total_transaction_amount,
    SUM(total_trans_vol) AS total_transaction_volume
FROM creditcard;

-- CARD CATEGORY ANALYSIS
SELECT
    card_category,
    COUNT(DISTINCT client_num) AS total_customer,
    AVG(credit_limit) AS avg_credit_limit,
    AVG(avg_utilization_ratio) AS avg_utilization,
    SUM(total_trans_amt) AS total_transaction_amount,
    SUM(total_trans_vol) AS total_transaction_volume
FROM creditcard
GROUP BY card_category
ORDER BY total_transaction_amount DESC;

-- REVENUE ANALYSIS
-- Menghitung estimasi pendapatan berdasarkan annual fee dan interest earned
SELECT
    SUM(annual_fees + interest_earned) AS estimated_revenue
FROM creditcard;

-- Menganalisis kontribusi revenue berdasarkan kategori kartu
SELECT
    card_category,
    COUNT(DISTINCT client_num) AS total_customer,
    SUM(total_trans_amt) AS total_transaction,
    SUM(total_trans_vol) AS transaction_volume,
    SUM(annual_fees) AS annual_fee_revenue,
    SUM(interest_earned) AS interest_revenue,
    SUM(annual_fees + interest_earned) AS estimated_revenue
FROM creditcard
GROUP BY card_category
ORDER BY estimated_revenue DESC;

-- CUSTOMER SEGMENT ANALYSIS
-- Menganalisis customer berdasarkan pekerjaan
SELECT
    customer_job,
    COUNT(DISTINCT client_num) AS total_customer,
    SUM(total_trans_amt) AS total_transaction,
    SUM(annual_fees + interest_earned) AS estimated_revenue
FROM creditcard
GROUP BY customer_job
ORDER BY estimated_revenue DESC;

-- Menganalisis customer berdasarkan income
SELECT
    income,
    COUNT(DISTINCT client_num) AS total_customer,
    AVG(credit_limit) AS avg_credit_limit,
    SUM(total_trans_amt) AS total_transaction,
    SUM(annual_fees + interest_earned) AS estimated_revenue
FROM creditcard
GROUP BY income
ORDER BY estimated_revenue DESC;

-- CREDIT RISK ANALYSIS
-- Menghitung total delinquent customer dan delinquency rate

SELECT
    COUNT(DISTINCT client_num) AS total_customer,

    SUM(
        CASE
            WHEN delinquent_acc = 1 THEN 1
            ELSE 0
        END
    ) AS delinquent_customer,

    ROUND(
        SUM(
            CASE
                WHEN delinquent_acc = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS delinquency_rate

FROM creditcard;

-- Analisis delinquency berdasarkan kategori kartu
SELECT
    card_category,
    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN delinquent_acc = 1 THEN 1
            ELSE 0
        END
    ) AS delinquent_customer,

    ROUND(
        AVG(
            CASE
                WHEN delinquent_acc = 1 THEN 1.0
                ELSE 0
            END
        ) * 100,
        2
    ) AS delinquency_rate

FROM creditcard
GROUP BY card_category
ORDER BY delinquency_rate DESC;

-- Membandingkan karakteristik customer delinquent dan non delinquent
SELECT
    delinquent_acc,
    COUNT(*) AS total_customer,
    AVG(credit_limit) AS avg_credit_limit,
    AVG(avg_utilization_ratio) AS avg_utilization,
    AVG(total_trans_amt) AS avg_transaction,
    AVG(total_trans_vol) AS avg_transaction_volume,
    AVG(cust_satisfaction_score) AS avg_satisfaction
FROM creditcard
GROUP BY delinquent_acc;

-- Menganalisis hubungan antara tingkat penggunaan kredit dengan risiko keterlambatan pembayaran
SELECT
    CASE
        WHEN avg_utilization_ratio < 0.30 THEN 'Low'
        WHEN avg_utilization_ratio < 0.70 THEN 'Medium'
        ELSE 'High'
    END AS utilization_category,

    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN delinquent_acc = 1 THEN 1
            ELSE 0
        END
    ) AS delinquent_customer,

    ROUND(
        AVG(
            CASE
                WHEN delinquent_acc = 1 THEN 1.0
                ELSE 0
            END
        ) * 100,
        2
    ) AS delinquency_rate

FROM creditcard
GROUP BY utilization_category
ORDER BY delinquency_rate DESC;

-- CUSTOMER ACTIVATION ANALYSIS
-- Mengukur tingkat aktivasi customer dalam 30 hari pertama
SELECT
    COUNT(*) AS total_customer,

    SUM(
        CASE
            WHEN activation_30_days = 1 THEN 1
            ELSE 0
        END
    ) AS activated_customer,

    ROUND(
        AVG(
            CASE
                WHEN activation_30_days = 1 THEN 1.0
                ELSE 0
            END
        ) * 100,
        2
    ) AS activation_rate

FROM creditcard;

-- Membandingkan karakteristik customer berdasarkan status aktivasi
SELECT
    activation_30_days,
    COUNT(*) AS total_customer,
    AVG(avg_utilization_ratio) AS avg_utilization,
    AVG(total_trans_amt) AS avg_transaction,
    AVG(total_trans_vol) AS avg_transaction_volume,
    AVG(cust_satisfaction_score) AS avg_satisfaction
FROM creditcard
GROUP BY activation_30_days;

-- Membuat ANALYTICS VIEW
CREATE VIEW vw_credit_card_analysis AS

SELECT
    *,

    CASE
        WHEN avg_utilization_ratio < 0.30 THEN 'Low'
        WHEN avg_utilization_ratio < 0.70 THEN 'Medium'
        ELSE 'High'
    END AS utilization_category,

    CASE
        WHEN delinquent_acc = 1 THEN 'Delinquent'
        ELSE 'Non Delinquent'
    END AS delinquency_status,

    CASE
        WHEN activation_30_days = 1 THEN 'Activated'
        ELSE 'Not Activated'
    END AS activation_status,

    annual_fees + interest_earned AS estimated_revenue

FROM creditcard;