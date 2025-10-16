
create table Shop
(
   ShopID int not null,
   ShopName varchar(20) not null,
   constraint pkShopID primary key (ShopID),
   constraint ukShopName unique (ShopName)
);
create index idxShop on Shop(ShopID);


create table Employee
(
   EmployeeID int not null,
   FirstName varchar(20) not null,
   LastName varchar(20) not null,
   constraint pkEmployeeID primary key (EmployeeID)
);
create index idxEmployee on Employee(EmployeeID);


create table EmployeeHistory
(
   EmployeeHistoryID int not null,
   EmployeeID int not null,
   ShopID int null,
   StartDate date not null,
   TerminationDate date null,
   constraint pkEmployeeHistoryID primary key (EmployeeHistoryID),
   constraint fkEmployeeHistoryEmployeeID foreign key (EmployeeID) references Employee (EmployeeID),   
   constraint fkEmployeeHistoryShopID foreign key (ShopID) references Shop (ShopID)
);
create index idxEmployeeHistory on EmployeeHistory(EmployeeHistoryID);


create table Customer
(
    CustomerID int not null,
    PhoneNumber varchar(15),
    Email varchar(40),
    LastName varchar(40),
    StreetAddress varchar(40),
    City Varchar(20),
    StateProvidence Varchar(10),
    PostalCode Varchar(15),
    constraint pkCustomerID primary key (CustomerID)
);
create index idxCustomer on Customer(CustomerID);


create table Coupon
(
    CouponID int not null,
    CouponName varchar(20)  unique not null,
    CouponDescription varchar(80),
    PercentDiscount int not null,
    ExpirationDate date not null,
    constraint pkCouponID primary key (CouponID)
);
create index idxCoupon on Coupon(CouponID);


create table Product
(
    ProductID int not null,
    ProductName varchar(20) not null,
    ProductType varchar(5) not null,
    Price decimal(12,2) not null,
    constraint pkProductID primary key (ProductID),
    constraint ukProductName unique (ProductName)
);
create index idxProduct on Product(ProductID);


create table CustomerOrder
(
    CustomerOrderID int not null,
    CustomerID int not null,
    OrderTakerID int not null,
    OrderDate date not null,
    CouponID int,
    constraint pkCustomerOrderID primary key (CustomerOrderID),
    constraint fkCustomerOrderCustomerID foreign key (CustomerID) references Customer (CustomerID),
    constraint fkCustomerOrderOrderTakerID foreign key (OrderTakerID) references Employee (EmployeeID),
    constraint fkCouponID foreign key (CouponID) references Coupon (CouponID)
);
create index idxCustomerOrder on CustomerOrder(CustomerOrderID);


create table CustomerOrderItem
(
    CustomerOrderItemID int not null,
    CustomerOrderID int not null,
    ProductID int not null,
    Quantity int not null,
    SpecialInstructions varchar(60),
    constraint pkCustomerOrderItemId primary key (CustomerOrderItemID),
    constraint fkCustomerOrderItemCustomerOrderID foreign key (CustomerOrderID) references CustomerOrder (CustomerOrderID),
    constraint fkCustomerOrderItemProductID foreign key (ProductID) references Product (ProductID)
);
create index idxCustomerOrderItem on CustomerOrderItem(CustomerOrderItemID);

create  view CustomerOrderDetail
as
select o.CustomerOrderID, o.OrderDate, c.CustomerID, c.LastName CustomerName,
    p.ProductName, p.Price, i.Quantity, i.Quantity * p.Price PurchaseAmount
from CustomerOrder o
    inner join Customer c on o.CustomerID = c.CustomerID
    inner join CustomerOrderItem i on  o.CustomerOrderID = i.CustomerOrderID
    inner join Product p on i.ProductID = p.ProductID;

create view CustomerOrderSummary
as
select o.CustomerOrderID, o.OrderDate, c.CustomerID, c.LastName, 
   Sum(i.Quantity * p.Price) OrderPrice,
   Sum(i.Quantity * p.Price) * coalesce(cp.PercentDiscount ,0) / 100.0 DiscountAmount,
   Sum(i.Quantity * p.Price) * (1.00 - (coalesce(cp.PercentDiscount ,0) / 100.0)) FinalOrderPrice
from CustomerOrder o
    inner join Customer c on o.CustomerID = c.CustomerID
    inner join CustomerOrderItem i on o.CustomerOrderID = i.CustomerOrderID
    inner join Product p on i.ProductID = p.ProductID
    left  join Coupon cp on o.CouponID = cp.CouponID
group by o.CustomerOrderID, o.OrderDate, c.CustomerID, c.LastName, cp.PercentDiscount;

create view DailySalesSummary
as
select OrderDate, Sum(FinalOrderPrice) DailySales
from CustomerOrderSummary
group by OrderDate;


create view EmployeeDetail
as
select h.EmployeeHistoryID, e.EmployeeID, s.ShopName, e.FirstName, e.LastName, h.StartDate, h.TerminationDate,
    case when TerminationDate is null then 1 else 0 end IsActive
from Employee e
    inner join EmployeeHistory h on e.EmployeeID = h.EmployeeID
    inner join Shop s on h.ShopId = s.ShopID;

