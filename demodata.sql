-- --------------------------------------------------------
-- Хост:                         127.0.0.1
-- Версия сервера:               10.3.27-MariaDB-1:10.3.27+maria~bionic - mariadb.org binary distribution
-- Операционная система:         debian-linux-gnu
-- HeidiSQL Версия:              11.1.0.6116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Дамп данных таблицы projectm.overlay: ~3 rows (приблизительно)
/*!40000 ALTER TABLE `overlay` DISABLE KEYS */;
INSERT INTO `overlay` (`id`, `name`, `geometryType`) VALUES
	(32, 'DemoPoint', 0),
	(33, 'Star', 1),
	(34, 'Polygon', 2);
/*!40000 ALTER TABLE `overlay` ENABLE KEYS */;

-- Дамп данных таблицы projectm.overlayСoordinates: ~12 rows (приблизительно)
/*!40000 ALTER TABLE `overlayСoordinates` DISABLE KEYS */;
INSERT INTO `overlayСoordinates` (`id`, `x`, `y`, `orderId`, `overlayId`) VALUES
	(534, -6414460, 3853800, 0, 32),
	(535, -5738710, 3366520, 0, 33),
	(536, -5430720, 4230740, 1, 33),
	(537, -5072160, 3361930, 2, 33),
	(538, -6042110, 4028480, 3, 33),
	(539, -4810140, 4014690, 4, 33),
	(540, -5724920, 3366520, 5, 33),
	(541, -4045560, 4385000, 0, 34),
	(542, -4074230, 3249590, 1, 34),
	(543, -2950280, 3261060, 2, 34),
	(544, -3007630, 4367800, 3, 34),
	(545, -4045560, 4385000, 4, 34);
/*!40000 ALTER TABLE `overlayСoordinates` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
