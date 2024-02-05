CREATE TABLE `telegrams` (
  `id` int(11) NOT NULL,
  `receiver` varchar(50) NOT NULL,
  `sender` varchar(50) NOT NULL,
  `message` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

ALTER TABLE `telegrams`
  ADD PRIMARY KEY (`id`),
  ADD KEY `receiver` (`receiver`);

ALTER TABLE `telegrams`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=315;
COMMIT;
