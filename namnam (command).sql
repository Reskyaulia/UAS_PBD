-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Waktu pembuatan: 15 Jul 2024 pada 17.52
-- Versi server: 10.4.28-MariaDB
-- Versi PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `namnam`
--

DELIMITER $$
--
-- Prosedur
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_getTotalProducts` ()   BEGIN
    DECLARE total INT;
    
    SELECT COUNT(*) INTO total
    FROM product;
    
    SELECT total AS total_products;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_updateProductStock` (IN `paramProductId` INT, IN `paramQuantityOrdered` INT)   BEGIN
    DECLARE currentStock INT;
    
    SELECT stock INTO currentStock FROM product WHERE id_product = paramProductId;
    
    IF currentStock >= paramQuantityOrdered THEN
        UPDATE product SET stock = stock - paramQuantityOrdered WHERE id_product = paramProductId;
        SELECT CONCAT('Stock updated for product with ID ', paramProductId) AS result;
    ELSE
        SELECT 'Insufficient stock to fulfill order' AS result;
    END IF;
    
END$$

--
-- Fungsi
--
CREATE DEFINER=`root`@`localhost` FUNCTION `total_order_price` (`p_id_order` INT) RETURNS DECIMAL(10,2)  BEGIN
    DECLARE product_price DECIMAL(10,2);
    DECLARE varian_price DECIMAL(10,2);
    DECLARE quantity INT;
    DECLARE id_product INT;
    DECLARE total_price DECIMAL(10,2);

    -- Retrieve order details
    SELECT o.id_product, o.qty INTO id_product, quantity 
    FROM `orders` o 
    WHERE o.id_order = p_id_order
    LIMIT 1;

    -- Retrieve product prices
    SELECT p.product_price, COALESCE(p.varian_price, 0) INTO product_price, varian_price 
    FROM product p 
    WHERE p.id_product = id_product
    LIMIT 1;

    -- Calculate total price
    SET total_price = (product_price + varian_price) * quantity;

    RETURN total_price;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `total_stock` () RETURNS INT(11)  BEGIN
    DECLARE total INT;
    SELECT SUM(stock) INTO total FROM product;
    RETURN total;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `category`
--

CREATE TABLE `category` (
  `id_category` int(11) NOT NULL,
  `category_name` char(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `category`
--

INSERT INTO `category` (`id_category`, `category_name`) VALUES
(1, 'Cookies'),
(2, 'Brownies'),
(3, 'Marble'),
(4, 'Sponge'),
(5, 'Bread');

-- --------------------------------------------------------

--
-- Struktur dari tabel `customer`
--

CREATE TABLE `customer` (
  `id_customer` int(11) NOT NULL,
  `customer_name` char(50) DEFAULT NULL,
  `phone_num` char(50) DEFAULT NULL,
  `address` char(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `customer`
--

INSERT INTO `customer` (`id_customer`, `customer_name`, `phone_num`, `address`) VALUES
(1, 'Argatha Bintang Mahesa', '0812345678', 'Magelang'),
(2, 'Gabriel Keenan Fareza', '08514064818', 'Semarang'),
(3, 'Yuniar Kastiel Dewa', '0892968487507', 'Semarang'),
(4, 'El Gema', '0861645747098', 'Yogyakarta'),
(5, 'Claudya Maurelina', '083673732451', 'Yogyakarta'),
(6, 'Sema Stellata', '0849544180576', 'Magelang');

-- --------------------------------------------------------

--
-- Struktur dari tabel `customer_orders`
--

CREATE TABLE `customer_orders` (
  `order_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `order_date` date DEFAULT NULL,
  `total_amount` decimal(10,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `orders`
--

CREATE TABLE `orders` (
  `id_order` int(11) NOT NULL,
  `id_customer` int(11) DEFAULT NULL,
  `id_product` int(11) DEFAULT NULL,
  `order_date` date DEFAULT NULL,
  `qty` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `orders`
--

INSERT INTO `orders` (`id_order`, `id_customer`, `id_product`, `order_date`, `qty`) VALUES
(1, 1, 6, '2024-07-10', 1),
(2, 6, 13, '2024-07-10', 3),
(3, 5, 10, '2024-07-10', 2),
(4, 4, 2, '2024-07-10', 3),
(5, 2, 15, '2024-07-10', 4),
(6, 3, 9, '2024-07-10', 2);

-- --------------------------------------------------------

--
-- Struktur dari tabel `product`
--

CREATE TABLE `product` (
  `id_product` int(11) NOT NULL,
  `product_name` char(50) NOT NULL,
  `product_varian` char(50) NOT NULL,
  `product_price` decimal(10,0) NOT NULL,
  `varian_price` decimal(10,0) NOT NULL,
  `size` enum('Small','Medium','Large') NOT NULL,
  `stock` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `product`
--

INSERT INTO `product` (`id_product`, `product_name`, `product_varian`, `product_price`, `varian_price`, `size`, `stock`) VALUES
(2, 'Roll Cake Jelly', 'Mango', 28000, 3000, 'Medium', 180),
(4, 'Brownies', 'Strawberry', 50000, 3000, 'Small', 10),
(5, 'Fudgy Brownies', '', 70000, 0, 'Small', 10),
(6, 'Iced Fudgy Brownies', '', 75000, 0, 'Small', 20),
(7, 'Classic Marble Cake', '', 40000, 0, 'Medium', 30),
(8, 'Kastengel', '', 60000, 0, 'Medium', 25),
(9, 'Classic Nastar', '', 60000, 0, 'Medium', 50),
(10, 'Black Nastar', 'Chocolate', 60000, 4000, 'Medium', 30),
(12, 'Palm', '', 50000, 0, 'Medium', 50),
(13, 'Palm', 'Cheese', 50000, 5000, 'Medium', 45),
(14, 'White Bread', '', 25000, 0, 'Large', 35),
(15, 'Wheat Bread', '', 22000, 0, 'Medium', 30),
(16, 'Lava Cake', 'Vanilla', 40000, 5000, 'Small', 50),
(17, 'Product A', '', 20000, 0, 'Small', 100),
(18, 'Product B', '', 30000, 0, 'Small', 200),
(19, 'New Product', '', 60000, 0, 'Small', 0);

--
-- Trigger `product`
--
DELIMITER $$
CREATE TRIGGER `after_product_delete` AFTER DELETE ON `product` FOR EACH ROW BEGIN
    INSERT INTO product_log (product_id, action, old_stock, old_price)
    VALUES (OLD.id_product, 'AFTER DELETE', OLD.stock, OLD.product_price);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_product_insert` AFTER INSERT ON `product` FOR EACH ROW BEGIN
    INSERT INTO product_log (product_id, action, new_stock, new_price)
    VALUES (NEW.id_product, 'AFTER INSERT', NEW.stock, NEW.product_price);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `after_product_update` AFTER UPDATE ON `product` FOR EACH ROW BEGIN
    INSERT INTO product_log (product_id, action, old_stock, new_stock, old_price, new_price)
    VALUES (OLD.id_product, 'AFTER UPDATE', OLD.stock, NEW.stock, OLD.product_price, NEW.product_price);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_product_delete` BEFORE DELETE ON `product` FOR EACH ROW BEGIN
    -- Hapus entri terkait di tabel product_category
    DELETE FROM product_category WHERE id_product = OLD.id_product;
    
    -- Log penghapusan produk di tabel product_log
    INSERT INTO product_log (product_id, action, old_stock, old_price)
    VALUES (OLD.id_product, 'DELETE', OLD.stock, OLD.product_price);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_product_insert` BEFORE INSERT ON `product` FOR EACH ROW BEGIN
    INSERT INTO product_log (product_id, action, new_stock, new_price)
    VALUES (NEW.id_product, 'INSERT', NEW.stock, NEW.product_price);
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `before_product_update` BEFORE UPDATE ON `product` FOR EACH ROW BEGIN
    INSERT INTO product_log (product_id, action, old_stock, new_stock, old_price, new_price)
    VALUES (OLD.id_product, 'UPDATE', OLD.stock, NEW.stock, OLD.product_price, NEW.product_price);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Struktur dari tabel `product_category`
--

CREATE TABLE `product_category` (
  `id_product_category` int(11) NOT NULL,
  `id_product` int(11) DEFAULT NULL,
  `id_category` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `product_category`
--

INSERT INTO `product_category` (`id_product_category`, `id_product`, `id_category`) VALUES
(2, 2, 3),
(4, 4, 2),
(5, 5, 2),
(6, 6, 2),
(7, 7, 1),
(8, 7, 3),
(9, 8, 1),
(10, 8, 3),
(11, 9, 1),
(12, 9, 3),
(13, 10, 1),
(14, 10, 3),
(16, 4, 2),
(17, 5, 2),
(18, 6, 2),
(19, 7, 1),
(20, 7, 3),
(21, 8, 1),
(22, 8, 3),
(23, 9, 1),
(24, 9, 3),
(25, 10, 1),
(26, 10, 3),
(28, 10, 3),
(30, 10, 3),
(31, 10, 3),
(32, 12, 1),
(33, 12, 3),
(34, 13, 1),
(35, 13, 3),
(36, 14, 5),
(37, 15, 5);

-- --------------------------------------------------------

--
-- Struktur dari tabel `product_log`
--

CREATE TABLE `product_log` (
  `log_id` int(11) NOT NULL,
  `product_id` int(11) DEFAULT NULL,
  `action` varchar(50) DEFAULT NULL,
  `old_stock` int(11) DEFAULT NULL,
  `new_stock` int(11) DEFAULT NULL,
  `old_price` decimal(10,0) DEFAULT NULL,
  `new_price` decimal(10,0) DEFAULT NULL,
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `product_log`
--

INSERT INTO `product_log` (`log_id`, `product_id`, `action`, `old_stock`, `new_stock`, `old_price`, `new_price`, `changed_at`) VALUES
(2, 17, 'INSERT', NULL, 100, NULL, 20000, '2024-07-15 13:35:41'),
(3, 1, 'UPDATE', 25, 150, 30000, 25000, '2024-07-15 13:38:46'),
(6, 1, 'DELETE', 150, NULL, 25000, NULL, '2024-07-15 13:52:23'),
(8, 18, 'INSERT', NULL, 200, NULL, 30000, '2024-07-15 13:56:05'),
(9, 18, 'AFTER INSERT', NULL, 200, NULL, 30000, '2024-07-15 13:56:05'),
(10, 2, 'UPDATE', 25, 180, 30000, 28000, '2024-07-15 13:58:42'),
(11, 2, 'AFTER UPDATE', 25, 180, 30000, 28000, '2024-07-15 13:58:42'),
(15, 3, 'DELETE', 10, NULL, 50000, NULL, '2024-07-15 14:48:39'),
(16, 3, 'AFTER DELETE', 10, NULL, 50000, NULL, '2024-07-15 14:48:39'),
(18, 19, 'INSERT', NULL, 0, NULL, 60000, '2024-07-15 15:36:11'),
(19, 19, 'AFTER INSERT', NULL, 0, NULL, 60000, '2024-07-15 15:36:11');

-- --------------------------------------------------------

--
-- Struktur dari tabel `transaction`
--

CREATE TABLE `transaction` (
  `id_transaction` int(11) NOT NULL,
  `id_order` int(11) DEFAULT NULL,
  `id_customer` int(11) DEFAULT NULL,
  `id_product` int(11) DEFAULT NULL,
  `total` decimal(10,0) DEFAULT NULL,
  `payment` enum('Cash','Transfer') DEFAULT NULL,
  `transaction_date` date DEFAULT NULL,
  `status` enum('Success','Failed') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `transaction`
--

INSERT INTO `transaction` (`id_transaction`, `id_order`, `id_customer`, `id_product`, `total`, `payment`, `transaction_date`, `status`) VALUES
(1, 1, 1, 6, 75000, 'Transfer', '2024-07-10', 'Success'),
(2, 2, 6, 13, 165000, 'Transfer', '2024-07-10', 'Success'),
(3, 3, 5, 10, 132000, 'Cash', '2024-07-10', 'Success'),
(4, 4, 4, 2, 66000, 'Cash', '2024-07-10', 'Success'),
(5, 5, 2, 15, 88000, 'Cash', '2024-07-10', 'Success'),
(6, 6, 3, 9, 120000, 'Transfer', '2024-07-10', 'Success');

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_expensive_product_category`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_expensive_product_category` (
`id_product` int(11)
,`product_name` char(50)
,`category_name` char(50)
,`product_price` decimal(10,0)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_high_stock_products`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_high_stock_products` (
`id_product` int(11)
,`product_name` char(50)
,`product_varian` char(50)
,`product_price` decimal(10,0)
,`varian_price` decimal(10,0)
,`size` enum('Small','Medium','Large')
,`stock` int(11)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_product_category`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_product_category` (
`id_product` int(11)
,`product_name` char(50)
,`category_name` char(50)
,`product_price` decimal(10,0)
);

-- --------------------------------------------------------

--
-- Stand-in struktur untuk tampilan `v_product_summary`
-- (Lihat di bawah untuk tampilan aktual)
--
CREATE TABLE `v_product_summary` (
`id_product` int(11)
,`product_name` char(50)
,`product_price` decimal(10,0)
);

-- --------------------------------------------------------

--
-- Struktur untuk view `v_expensive_product_category`
--
DROP TABLE IF EXISTS `v_expensive_product_category`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_expensive_product_category`  AS SELECT `v_product_category`.`id_product` AS `id_product`, `v_product_category`.`product_name` AS `product_name`, `v_product_category`.`category_name` AS `category_name`, `v_product_category`.`product_price` AS `product_price` FROM `v_product_category` WHERE `v_product_category`.`product_price` > 50000WITH CASCADEDCHECK OPTION  ;

-- --------------------------------------------------------

--
-- Struktur untuk view `v_high_stock_products`
--
DROP TABLE IF EXISTS `v_high_stock_products`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_high_stock_products`  AS SELECT `product`.`id_product` AS `id_product`, `product`.`product_name` AS `product_name`, `product`.`product_varian` AS `product_varian`, `product`.`product_price` AS `product_price`, `product`.`varian_price` AS `varian_price`, `product`.`size` AS `size`, `product`.`stock` AS `stock` FROM `product` WHERE `product`.`stock` > 50 ;

-- --------------------------------------------------------

--
-- Struktur untuk view `v_product_category`
--
DROP TABLE IF EXISTS `v_product_category`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_product_category`  AS SELECT `p`.`id_product` AS `id_product`, `p`.`product_name` AS `product_name`, `c`.`category_name` AS `category_name`, `p`.`product_price` AS `product_price` FROM ((`product` `p` join `product_category` `pc` on(`p`.`id_product` = `pc`.`id_product`)) join `category` `c` on(`pc`.`id_category` = `c`.`id_category`)) ;

-- --------------------------------------------------------

--
-- Struktur untuk view `v_product_summary`
--
DROP TABLE IF EXISTS `v_product_summary`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_product_summary`  AS SELECT `product`.`id_product` AS `id_product`, `product`.`product_name` AS `product_name`, `product`.`product_price` AS `product_price` FROM `product` ;

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `category`
--
ALTER TABLE `category`
  ADD PRIMARY KEY (`id_category`);

--
-- Indeks untuk tabel `customer`
--
ALTER TABLE `customer`
  ADD PRIMARY KEY (`id_customer`);

--
-- Indeks untuk tabel `customer_orders`
--
ALTER TABLE `customer_orders`
  ADD PRIMARY KEY (`order_id`,`customer_id`),
  ADD KEY `idx_order_date` (`order_date`),
  ADD KEY `idx_total_amount` (`total_amount`);

--
-- Indeks untuk tabel `orders`
--
ALTER TABLE `orders`
  ADD PRIMARY KEY (`id_order`),
  ADD KEY `id_customer` (`id_customer`),
  ADD KEY `id_product` (`id_product`);

--
-- Indeks untuk tabel `product`
--
ALTER TABLE `product`
  ADD PRIMARY KEY (`id_product`);

--
-- Indeks untuk tabel `product_category`
--
ALTER TABLE `product_category`
  ADD PRIMARY KEY (`id_product_category`),
  ADD KEY `id_product` (`id_product`),
  ADD KEY `id_category` (`id_category`);

--
-- Indeks untuk tabel `product_log`
--
ALTER TABLE `product_log`
  ADD PRIMARY KEY (`log_id`);

--
-- Indeks untuk tabel `transaction`
--
ALTER TABLE `transaction`
  ADD PRIMARY KEY (`id_transaction`),
  ADD KEY `id_order` (`id_order`),
  ADD KEY `id_customer` (`id_customer`),
  ADD KEY `id_product` (`id_product`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `category`
--
ALTER TABLE `category`
  MODIFY `id_category` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT untuk tabel `customer`
--
ALTER TABLE `customer`
  MODIFY `id_customer` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `orders`
--
ALTER TABLE `orders`
  MODIFY `id_order` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `product`
--
ALTER TABLE `product`
  MODIFY `id_product` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT untuk tabel `product_category`
--
ALTER TABLE `product_category`
  MODIFY `id_product_category` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- AUTO_INCREMENT untuk tabel `product_log`
--
ALTER TABLE `product_log`
  MODIFY `log_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT untuk tabel `transaction`
--
ALTER TABLE `transaction`
  MODIFY `id_transaction` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `orders`
--
ALTER TABLE `orders`
  ADD CONSTRAINT `orders_ibfk_1` FOREIGN KEY (`id_customer`) REFERENCES `customer` (`id_customer`),
  ADD CONSTRAINT `orders_ibfk_2` FOREIGN KEY (`id_product`) REFERENCES `product` (`id_product`);

--
-- Ketidakleluasaan untuk tabel `product_category`
--
ALTER TABLE `product_category`
  ADD CONSTRAINT `product_category_ibfk_1` FOREIGN KEY (`id_product`) REFERENCES `product` (`id_product`),
  ADD CONSTRAINT `product_category_ibfk_2` FOREIGN KEY (`id_category`) REFERENCES `category` (`id_category`);

--
-- Ketidakleluasaan untuk tabel `transaction`
--
ALTER TABLE `transaction`
  ADD CONSTRAINT `transaction_ibfk_1` FOREIGN KEY (`id_order`) REFERENCES `orders` (`id_order`),
  ADD CONSTRAINT `transaction_ibfk_2` FOREIGN KEY (`id_customer`) REFERENCES `customer` (`id_customer`),
  ADD CONSTRAINT `transaction_ibfk_3` FOREIGN KEY (`id_product`) REFERENCES `product` (`id_product`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
