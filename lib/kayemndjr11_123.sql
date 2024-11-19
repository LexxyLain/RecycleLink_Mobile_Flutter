-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Nov 10, 2024 at 06:33 AM
-- Server version: 10.5.22-MariaDB-log
-- PHP Version: 8.3.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `kayemndjr11_123`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin_users`
--

CREATE TABLE `admin_users` (
  `admin_id` int(11) NOT NULL,
  `username` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `admin_users`
--

INSERT INTO `admin_users` (`admin_id`, `username`, `email`, `password`) VALUES
(1, 'kayegm', 'kayegm@gmail.com', '$2y$10$Mzsuk4R.ichKNSH70v4xlON01rPuxI/niJPgP.oXpCQsCwDtIKUgK'),
(2, 'kaye', 'k@gmail.com', '$2y$10$ww6C2t9aVl5WcJC0ZXulxONdgtzTsUVwazGvpuF8lIonCuNOdUoya'),
(3, 'kirby', 'armor@gmail.com', '$2y$10$QXMU5chMWcBt4wibrPKw1u.6ONb6cTkPhVaU196b1dTewgJeEGem.'),
(4, 'PART', 'part@gmail.com', '$2y$10$H.zc.DWAk92SQidqJYOIkucVBXqd.cq4fe3dHEN4HfMNvjrzthvIq');

-- --------------------------------------------------------

--
-- Table structure for table `collectors`
--

CREATE TABLE `collectors` (
  `id` int(11) NOT NULL,
  `fullname` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(11) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `address` varchar(255) NOT NULL,
  `police_clearance` varchar(255) DEFAULT NULL,
  `valid_id` varchar(255) DEFAULT NULL,
  `registration_date` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `collectors`
--

INSERT INTO `collectors` (`id`, `fullname`, `email`, `password`, `phone`, `address`, `police_clearance`, `valid_id`, `registration_date`) VALUES
(1, 'kaye mondejar', 'kaye@gmail.com', '0', '09752328330', 'Sipalay City', NULL, NULL, '2024-11-06 16:33:20'),
(2, 'JIl Yap', 'jil@email.com', '0', '09950726466', 'Binalbagan', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 06:12:45'),
(22, 'as as', 'as@email.com', '0', '12345678', 'NInalbagan', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 06:14:52'),
(23, 'kaye villa', 'kvilla@email.com', '0', '123456789', 'Murcia', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 06:26:41'),
(24, 'stef del', 'stef@email.com', '$2y$10$jX.d', '123465', 'Murcia', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 06:42:28'),
(28, 'jil monti', 'jilmon@email.com', '$2y$10$vZ0x', '1212121212', 'Paglaum 2', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 12:43:54'),
(36, 'dwed qsd', 'scbi@email.com', '$2y$10$8DJZ', '12112212', 'owdnoi', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 12:47:03'),
(41, 'leklek monmon', 'monlek@email.com', '$2y$10$GiRO', '09090909', '09090909', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 12:56:40'),
(42, 'kkkk lllllllll', 'lk@email.com', '$2y$10$rmR/', '111111111', '1111', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 13:01:49'),
(45, 'JILLIAN AYAP', 'jilayap@email.com', '$2y$10$Q7Gb', '090908080707', 'binalbagan', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 13:03:25'),
(46, 'kam mille', 'kam@email.com', '$2y$10$/k5L', '898392392', 'Bi-ao', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 13:14:27'),
(47, 'JIllian Ayap', 'jilyap@email.com', '$2y$10$6BPs', '09950726466', 'Paglaum', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 13:26:19'),
(50, 'Erika Cas', 'rik@email.com', '$2y$10$Mn5H', '1234567899', 'Phase 1', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 13:36:58'),
(51, 'Lexxy Arnado', 'lex@email.com', '$2y$10$Vqym', '123', 'Mircua', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 13:54:50'),
(52, 'leksie lek', 'lek@email.com', '$2y$10$ahkj', '9898', 'Mur', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-08 13:56:37'),
(59, 'Jimuel Ayap', 'jim@email.com', '$2y$10$nPcx', '8788', 'Ft', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-09 15:10:50'),
(60, 'Jersey Setera', 'jers@email.com', '$2y$10$xwoM', '099999', 'Ponte', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-09 15:13:25'),
(61, 'Von Estilles', 'v@email.com', '$2y$10$kNAV', '3623623', 'Ma-ao', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-09 15:21:57'),
(62, 'Jian Gapulan', 'jg@email.com', '$2y$10$YUPQ', '12345', 'San Carlos', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-09 15:49:00'),
(63, 'Lex Villa', 'Lex@gmail.com', '$2y$10$0DDS', '09876543212', 'Murcia', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-09 16:00:22'),
(64, 'Lexxy Lian', 'lain@gmail.com', '$2y$10$LYwY', '09952713627', 'Bacolod', 'uploads/police_clearance.jpg', 'uploads/valid_id.jpg', '2024-11-10 04:33:47');

-- --------------------------------------------------------

--
-- Table structure for table `collector_registration`
--

CREATE TABLE `collector_registration` (
  `id` int(11) NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `address` varchar(255) NOT NULL,
  `police_clearance` varchar(255) NOT NULL,
  `status` enum('Pending','Approved','Rejected') DEFAULT 'Pending',
  `valid_id` blob DEFAULT NULL,
  `password` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `collector_registration`
--

INSERT INTO `collector_registration` (`id`, `full_name`, `email`, `phone`, `address`, `police_clearance`, `status`, `valid_id`, `password`) VALUES
(1, 'saviel james', 'savj@gmail.com', '09752328330', 'Ayala Subdivision', '', 'Pending', NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `pickups`
--

CREATE TABLE `pickups` (
  `pickup_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `collector_id` int(11) NOT NULL,
  `weight_kg` decimal(10,2) NOT NULL,
  `status` enum('Pending','Completed','Cancelled') DEFAULT 'Pending',
  `pickup_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `cancellation_reason` varchar(255) DEFAULT NULL,
  `cancellation_date` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `transaction_history`
--

CREATE TABLE `transaction_history` (
  `transaction_id` int(10) NOT NULL,
  `user_id` int(10) NOT NULL,
  `collector_id` int(10) NOT NULL,
  `pickup_date` date NOT NULL DEFAULT current_timestamp(),
  `status` varchar(100) NOT NULL,
  `created_date` date NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `full_name` varchar(50) NOT NULL,
  `email` varchar(50) NOT NULL,
  `phone` bigint(20) DEFAULT NULL,
  `address` varchar(100) NOT NULL,
  `registration_date` datetime DEFAULT current_timestamp(),
  `password` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `full_name`, `email`, `phone`, `address`, `registration_date`, `password`) VALUES
(1, 'kaye', 'kaye@gmail.com', 9752328330, 'brgy. Gil montilla', '2024-11-08 16:39:04', '123'),
(2, 'louie', 'lou@gmail.com', 9752328330, 'Brgy Alijis, Bacolod City', '2024-11-08 16:39:52', '123'),
(3, 'Jillian Ayap', 'lj@email.com', 909080809, 'Binalbagan', '2024-11-09 14:40:51', '$2y$10$VjrtuYJlqvbfjwb9Lde8NeFJnMfAsO0vnws9F43dBA2xkaDrL53/a'),
(4, 'Kaye Mondejar', 'k@email.com', 12345, 'Sipalay', '2024-11-09 14:53:14', '$2y$10$X5kfg84c/LH.7tSydQSWFerLp1/P7xWmneJ3If/cWXnvQmHY40cTS'),
(5, 'Jillian Montinola', 'jm@email.com', 1232133, 'Binalbagan', '2024-11-09 15:02:25', '$2y$10$nyESRtKin.gq8G.v70qjm.E9jlQ2MtQQ4keCSYqsGmrCi2iUcgsT2'),
(6, 'Lex Villa', 'lek@gmail.com', 9976875432, 'Bacolod City', '2024-11-09 16:41:38', '$2y$10$idh59MDpy378KNEfzSV4BOv2ofAlyHvzXz79gKaPvyldECyptDqgq'),
(7, 'lek lek', 'lek2@gmail.com', 12345, 'murcia', '2024-11-09 17:40:34', '$2y$10$CJZxKHX2r.RBjbpuKB.3neZzIsFxteaYpIc2Cuu9kum3625X2cm2i');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_users`
--
ALTER TABLE `admin_users`
  ADD PRIMARY KEY (`admin_id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `collectors`
--
ALTER TABLE `collectors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `collector_registration`
--
ALTER TABLE `collector_registration`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `pickups`
--
ALTER TABLE `pickups`
  ADD PRIMARY KEY (`pickup_id`);

--
-- Indexes for table `transaction_history`
--
ALTER TABLE `transaction_history`
  ADD PRIMARY KEY (`transaction_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_users`
--
ALTER TABLE `admin_users`
  MODIFY `admin_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `collectors`
--
ALTER TABLE `collectors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=66;

--
-- AUTO_INCREMENT for table `collector_registration`
--
ALTER TABLE `collector_registration`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `pickups`
--
ALTER TABLE `pickups`
  MODIFY `pickup_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transaction_history`
--
ALTER TABLE `transaction_history`
  MODIFY `transaction_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
