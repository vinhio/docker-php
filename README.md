Docker PHP5

Old projects always bring a lot of trouble. One of them is that the development environment at the moment has no good support. Some very old project handle session by calling $_SESSION directly, Use PHP and HTML code inside php file. But you can not merge to some famous framework likes Laravel/Symfony and so on. In addition, how can you improve and make it more timely but still rely on the current code instead of having to break by a full version of all.

Docker PHP5 is created with that purpose. Help you become more comfortable working with older customers' code. And modernizing legacy applications in PHP 5 :).

Adaptation:
- Docker/Docker composer
- OS Alpine 3.8
- Web Nginx 1.2 
- PHP 5.6.40 (PHP-FPM)
- MySQL 5.7.35 / MySQL 8
- XDebug
- SMTP & Mail client

Development & Evolution
	This section is useful for project code in the 2000s. The type of handling each page per a PHP file. Sharing common libraries via include.php file. Then pages must require include.php at the top of each file. Don't have Routing, ORM, Controller, View

- Add API for Ajax request
- Check code style with PHP Linter
- Use `PHP composer 2` We also apply to use PHP Composer to install the huge PHP lib through https://packagist.org/
- More
	+ Use `illuminate/database:v5.4.36` and `illuminate/events:v5.4.36` ORM for Persistance layer, Database migration
	+ Use `swiftmailer/swiftmailer:v5.4.12` for Mailer library.
	+ Use `klein/klein:v2.1.2` for Routing .
	+ Use `latte/latte:v2.4.9` for View template.
	+ Use `league/flysystem-aws-s3-v3:1.0.29` (A library use in Laravel framwork) for File system.
	+ Use `vlucas/phpdotenv:v4.2.0` for load .env config

Even we can apply some https://phptherightway.com/ :)
