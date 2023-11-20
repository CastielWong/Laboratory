CREATE PARTITION SCHEME [ps_year]
    AS PARTITION [pf_year]
TO (
    [file_2020]
    , [file_2021], [file_2022], [file_2023], [file_2024], [file_2025]
    , [file_2026], [file_2027], [file_2028], [file_2029], [file_2030]
)
GO
