with stg_orders as (
    select * from {{ source('northwind', 'Orders') }}
),
stg_order_details as (
    select * from {{ source('northwind', 'Order_Details') }}
),
stg_products as (
    select * from {{ source('northwind', 'Products') }}
),
stg_customers as (
    select * from {{ source('northwind', 'Customers') }}
),
stg_employees as (
    select * from {{ source('northwind', 'Employees') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['o.orderid', 'od.productid']) }} as saleskey,
    o.orderid,
    {{ dbt_utils.generate_surrogate_key(['o.customerid']) }} as customerkey,
    {{ dbt_utils.generate_surrogate_key(['o.employeeid']) }} as employeekey,
    {{ dbt_utils.generate_surrogate_key(['od.productid']) }} as productkey,
    replace(to_date(o.orderdate)::varchar,'-','')::int as orderdatekey,
    od.quantity,
    od.unitprice,
    od.discount,
    (od.quantity * od.unitprice * (1 - od.discount)) as totalamount
from stg_orders o
join stg_order_details od on o.orderid = od.orderid
join stg_products p on od.productid = p.productid