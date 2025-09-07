create database inventory;
use inventory;
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
) ENGINE=InnoDB;

CREATE TABLE suppliers (
    supplier_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    contact_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(100),
    address TEXT
) ENGINE=InnoDB;




CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category_id INT,
    supplier_id INT,
    unit_price DECIMAL(10,2) NOT NULL,
    units_in_stock INT DEFAULT 0,
    units_on_order INT DEFAULT 0,
    reorder_level INT DEFAULT 0,
    discontinued BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
) ENGINE=InnoDB;

CREATE TABLE sales (
    sale_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE TABLE purchases (
    purchase_id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT,
    supplier_id INT,
    quantity INT NOT NULL,
    purchase_date DATE NOT NULL,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
) ENGINE=InnoDB;


DELIMITER $$
CREATE TRIGGER after_sale_insert
AFTER INSERT ON sales
FOR EACH ROW
BEGIN
    UPDATE products
    SET units_in_stock = units_in_stock - NEW.quantity
    WHERE product_id = NEW.product_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER after_purchase_insert
AFTER INSERT ON purchases
FOR EACH ROW
BEGIN
    UPDATE products
    SET units_in_stock = units_in_stock + NEW.quantity
    WHERE product_id = NEW.product_id;
END $$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER before_sale_insert
BEFORE INSERT ON sales
FOR EACH ROW
BEGIN
    IF (SELECT units_in_stock FROM products WHERE product_id = NEW.product_id) < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock for this sale';
    END IF;
END $$
DELIMITER ;





CREATE VIEW monthly_sales_report AS
SELECT
    DATE_FORMAT(sale_date, '%Y-%m') AS sale_month,
    p.product_id,
    p.name AS product_name,
    SUM(s.quantity) AS total_quantity_sold,
    SUM(s.quantity * p.unit_price) AS total_sales_amount
FROM sales s
JOIN products p ON s.product_id = p.product_id
GROUP BY sale_month, p.product_id, p.name
ORDER BY sale_month DESC, total_sales_amount DESC;



INSERT INTO categories (name, description) VALUES
('Electronics', 'Mobiles, laptops, and accessories'),
('Furniture', 'Home and office furniture'),
('Fashion', 'Clothing and accessories'),
('Groceries', 'Daily essentials and food items'),
('Appliances', 'Home & Kitchen appliances'),
('Books', 'Educational, fiction, and non-fiction books'),
('Beauty & Personal Care', 'Cosmetics, skincare, grooming'),
('Sports & Outdoors', 'Sports gear and equipment');

select * from categories;

INSERT INTO suppliers (name, contact_name, phone, email, address) VALUES
('Samsung India', 'Ravi Kumar', '9876543210', 'support@samsung.com', 'Bangalore, Karnataka'),
('Ikea India', 'Ananya Sharma', '9123456789', 'sales@ikea.in', 'Hyderabad, Telangana'),
('Nike India', 'Amit Patel', '9988776655', 'nike@sportswear.com', 'Mumbai, Maharashtra'),
('ITC Limited', 'Sunita Verma', '9811122233', 'itc@grocery.com', 'Kolkata, West Bengal'),
('LG Electronics', 'Rajesh Singh', '9001234567', 'lg@electronics.com', 'Chennai, Tamil Nadu'),
('Penguin Books', 'Meera Joshi', '9797979797', 'penguin@books.com', 'Delhi, India'),
('L’Oreal India', 'Priya Kapoor', '9765432109', 'loreal@beauty.com', 'Mumbai, Maharashtra'),
('Decathlon', 'Karan Mehta', '9808080808', 'sports@decathlon.com', 'Pune, Maharashtra');


INSERT INTO products (name, category_id, supplier_id, unit_price, units_in_stock, reorder_level) VALUES
-- Electronics
('Samsung Galaxy S23', 1, 1, 74999.00, 100, 20),
('Dell Inspiron Laptop', 1, 1, 55000.00, 50, 10),
('Samsung 55-inch Smart TV', 1, 1, 60000.00, 30, 5),
('LG Refrigerator 260L', 5, 5, 22000.00, 40, 5),
('LG Washing Machine 7kg', 5, 5, 18000.00, 25, 5),

-- Furniture
('Wooden Dining Table', 2, 2, 15999.00, 25, 5),
('Office Chair', 2, 2, 6999.00, 60, 10),
('Queen Size Bed', 2, 2, 25000.00, 15, 3),

-- Fashion
('Nike Air Max Shoes', 3, 3, 5999.00, 200, 30),
('Puma T-shirt', 3, 3, 1299.00, 300, 50),
('Levi’s Jeans', 3, 3, 2999.00, 150, 20),

-- Groceries
('Aashirvaad Atta 10kg', 4, 4, 480.00, 500, 100),
('Tata Salt 1kg', 4, 4, 25.00, 1000, 200),
('Amul Butter 500g', 4, 4, 250.00, 300, 50),

-- Books
('Atomic Habits', 6, 6, 599.00, 100, 20),
('Rich Dad Poor Dad', 6, 6, 499.00, 120, 20),

-- Beauty & Personal Care
('L’Oreal Shampoo 500ml', 7, 7, 450.00, 200, 30),
('Maybelline Lipstick', 7, 7, 299.00, 250, 40),

-- Sports
('Cricket Bat', 8, 8, 1999.00, 80, 10),
('Football', 8, 8, 999.00, 100, 20),
('Yoga Mat', 8, 8, 799.00, 150, 30);

INSERT INTO purchases (product_id, supplier_id, quantity, purchase_date) VALUES
(1, 1, 50, '2024-05-15'),
(2, 1, 20, '2024-05-18'),
(3, 1, 10, '2024-06-05'),
(4, 5, 15, '2024-06-10'),
(5, 5, 10, '2024-06-15'),
(6, 2, 10, '2024-06-20'),
(7, 2, 30, '2024-07-01'),
(8, 2, 5, '2024-07-10'),
(9, 3, 100, '2024-07-15'),
(10, 3, 200, '2024-07-20'),
(11, 3, 50, '2024-08-01'),
(12, 4, 300, '2024-08-05'),
(13, 4, 500, '2024-08-08'),
(14, 4, 100, '2024-08-12'),
(15, 6, 50, '2024-08-20'),
(16, 6, 60, '2024-08-25'),
(17, 7, 100, '2024-09-01'),
(18, 7, 200, '2024-09-05'),
(19, 8, 50, '2024-09-10'),
(20, 8, 70, '2024-09-15'),
(21, 8, 120, '2024-09-18');


INSERT INTO sales (product_id, quantity, sale_date) VALUES
-- June sales
(1, 5, '2024-06-11'),
(2, 3, '2024-06-12'),
(4, 4, '2024-06-16'),
(6, 2, '2024-06-18'),
(9, 15, '2024-06-20'),
(12, 30, '2024-06-22'),
(14, 10, '2024-06-25'),

-- July sales
(1, 8, '2024-07-05'),
(3, 2, '2024-07-07'),
(7, 5, '2024-07-08'),
(9, 20, '2024-07-12'),
(10, 50, '2024-07-13'),
(13, 60, '2024-07-15'),
(16, 15, '2024-07-20'),
(18, 25, '2024-07-28'),

-- August sales
(2, 6, '2024-08-02'),
(5, 3, '2024-08-04'),
(8, 2, '2024-08-06'),
(11, 10, '2024-08-08'),
(12, 80, '2024-08-10'),
(15, 20, '2024-08-18'),
(17, 30, '2024-08-20'),
(19, 10, '2024-08-25'),

-- September sales
(1, 10, '2024-09-02'),
(2, 5, '2024-09-05'),
(7, 8, '2024-09-08'),
(10, 40, '2024-09-10'),
(14, 20, '2024-09-12'),
(16, 25, '2024-09-15'),
(18, 30, '2024-09-18'),
(21, 40, '2024-09-20');

select * from monthly_sales_report;


select * from products;

















