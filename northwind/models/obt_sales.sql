with f_sales as (
    select * from {{ ref('fact_sales') }}
),
d_customer as (
    select * from {{ ref('dim_customer') }}
),
d_employee as (
    select * from {{ ref('dim_employee') }}
),
d_product as (
    select * from {{ ref('dim_product') }}
),
d_date as (
    select * from {{ ref('dim_date') }}
)

select
    f.saleskey,
    f.orderid,
    f.orderdatekey,
    f.quantity,
    f.discount,
    f.totalamount,
    d_customer.*,
    d_employee.*,
    d_product.*,
    d_date.*
from f_sales f
left join d_customer on f.customerkey = d_customer.customerkey
left join d_employee on f.employeekey = d_employee.employeekey
left join d_product on f.productkey = d_product.productkey
left join d_date on f.orderdatekey = d_date.datekey

