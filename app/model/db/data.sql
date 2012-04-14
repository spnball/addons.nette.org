-- Adminer 3.3.3 MySQL dump

SET NAMES utf8;
SET foreign_key_checks = 0;
SET time_zone = 'SYSTEM';
SET sql_mode = 'NO_AUTO_VALUE_ON_ZERO';

INSERT INTO `addon` (`id`, `name`, `user_id`, `repository`, `description`, `updated_at`) VALUES
(1,	'WebLoader',	4,	'http://github.com/janmarek/WebLoader',	'Instalace\r\n=========\r\n\r\nZkopírujte obsah složky `WebLoader` do své aplikace.\r\n\r\nWebLoader je možné také získat přes balíčkovací systém \"Composer\":http://packagist.org/packages/JanMarek/WebLoader.\r\n\r\nPříklad použití\r\n===============\r\n\r\nCSS\r\n---\r\n\r\nTovárnička komponenty v presenteru:\r\n\r\n/--code php\r\n\r\npublic function createComponentCss()\r\n{\r\n	// připravíme seznam souborů\r\n	// FileCollection v konstruktoru může dostat výchozí adresář, pak není potřeba psát absolutní cesty\r\n	$files = new \\WebLoader\\FileCollection(WWW_DIR . \'/css\');\r\n	$files->addFiles(array(\r\n		\'style.css\',\r\n		WWW_DIR . \'/colorbox/colorbox.css\'\r\n	));\r\n\r\n	// kompilátoru seznam předáme a určíme adresář, kam má kompilovat\r\n	$compiler = \\WebLoader\\Compiler::createCssCompiler($files, WWW_DIR . \'/webtemp\');\r\n\r\n	// nette komponenta pro výpis <link>ů přijímá kompilátor a cestu k adresáři na webu\r\n	return new \\WebLoader\\Nette\\CssLoader($compiler, $this->template->basePath . \'/webtemp\');\r\n}\r\n\\--\r\n\r\nPoužití v šabloně:\r\n/--code html\r\n{control css}\r\n{* nebo pro vygenerování jiných souborů *}\r\n{control css \'base.css\', \'layout.css\', \'subfolder/text.css\'}\r\n\\--\r\n\r\nJavaScript\r\n----------\r\n\r\nTovárnička komponenty v presenteru:\r\n\r\n/--code php\r\npublic function createComponentJs()\r\n{\r\n	$files = new \\WebLoader\\FileCollection(WWW_DIR . \'/js\');\r\n	// můžeme načíst i externí js\r\n	$files->addRemoteFile(\'http://ajax.googleapis.com/ajax/libs/jquery/1.7/jquery.min.js\');\r\n	$files->addFiles(array(\'netteForms.js\', \'colorbox.js\', \'web.js\'));\r\n\r\n	$compiler = \\WebLoader\\Compiler::createJsCompiler($files, WWW_DIR . \'/webtemp\');\r\n\r\n	return new \\WebLoader\\Nette\\JavaScriptLoader($compiler, $this->template->basePath . \'/webtemp\');\r\n}\r\n\\--\r\n\r\nPoužití v šabloně:\r\n/--code html\r\n{control js}\r\n\\--\r\n\r\nHromadné přidání souborů\r\n------------------------\r\n\r\nWebLoader lze kombinovat s utilitou [Nette\\Utils\\Finder | doc:finder].\r\n\r\n/--code php\r\n$files->addFiles(Finder::findFiles(\'*.css\')->from(APP_DIR . \'/templates\'));\r\n\\--\r\n\r\nJiné chování při production a development módu\r\n------------------------------------------\r\n\r\n/--code php\r\n// při development módu vypne spojování souborů\r\n$dev = $presenter->context->parameters[\'developmentMode\'];\r\n$compiler->setJoinFiles($dev);\r\n\r\nif ($dev) {\r\n	$compiler->addFilter(callback(\'packJs\'));\r\n}\r\n\\--\r\n\r\nFiltry\r\n======\r\n\r\nPodobu vygenerovaného kódu lze ovlivnit použitím filtrů. Mohou to být libovolné callbacky, tedy anonymní funkce či objekty s magickou metodou __invoke. Filtry přijímají v parametrech řetězec `$code` a instanci Compileru. Registrují se pomocí metody `addFilter` na objektu `$compiler`.\r\n\r\nPokud je pro filtr důležité, jaký soubor zrovna zpracovává, lze jej registrovat pomocí metody `$compiler->addFileFilter()` a v tom případě dostane ve třetím parametru absolutní cestu k souboru. V prvním parametru je pak obsažen pouze kód právě zpracovávaného souboru.\r\n\r\nMinimalizovaný JavaScript pomocí filtrů a třídy [JavaScriptPacker | http://dean.edwards.name/download/#packer]\r\n------------------------------------\r\n\r\n/--code php\r\n$compiler->addFilter(function ($code) {\r\n	$packer = new JavaScriptPacker($code, \"None\");\r\n	return $packer->pack();\r\n});\r\n\\--\r\n\r\nChování JavaScriptPackeru je ale dost \"agresivní\"((nesnese vynechání středníku v JS)), takže bych pro minifikaci doporučil spíše knihovny \"jsmin\":https://github.com/rgrove/jsmin-php/ a \"cssmin\":http://code.google.com/p/cssmin/.\r\n\r\nLessFilter\r\n----------\r\n\r\nPokud chceme při psaní CSS využít preprocesoru Less, je nejdříve potřeba stáhnout knihovnu \"LessPHP\":https://github.com/leafo/lessphp/. Filtr LessFilter pak nechá zpracovat lessem všechny soubory s příponou less.\r\n\r\n/--php\r\n// filtr přidáme jednoduše\r\n$compiler->addFileFilter(new \\Webloader\\Filter\\LessFilter());\r\n\\--\r\n\r\nCSS s proměnnými pomocí filtru VariablesFilter\r\n----------------\r\n\r\n/--code php\r\n// proměnné filtru je možné nastavit buď přímo v konstruktoru\r\n$filter = new WebLoader\\Filter\\VariablesFilter(array(\r\n	\"cervena\" => \"red\",\r\n	\"zelena\" => \"green\",\r\n));\r\n\r\n// nebo pomocí magického __set\r\n$filter->modra = \"blue\";\r\n\r\n// podobu proměnné v css souboru lze nastavit také\r\n// $filter->setDelimiter(\"{\", \"}\");\r\n// výchozí hodnoty jsou {{$ a }}\r\n\r\n// nastavení filtru\r\n$compiler->addFilter($filter);\r\n\\--\r\n\r\nCSS soubor:\r\n\r\n/--code css\r\nbody {background: {{$cervena}}}\r\nh1 {color: {{$modra}}}\r\np {color: {{$zelena}}}\r\n\\--\r\n\r\nVýstup:\r\n/--code css\r\nbody {background: red}\r\nh1 {color: blue}\r\np {color: green}\r\n\\--\r\n\r\nV JavaScriptu lze proměnné výhodně použít pro nastavování URL adres na různé presentery či signály.\r\n\r\nPoužití pro deployment script\r\n=============================\r\n\r\nInstance třídy Compiler lze zaregistrovat do aplikačního kontejneru jako služby. Tyto služby si můžeme poté vytáhnout někde v deployment scriptu a naložit s ním zhruba takto:\r\n\r\n/--php\r\n$context->jsloader->generate(FALSE);\r\n$context->cssloader->generate(FALSE);\r\n\\--\r\n\r\n/--comment\r\n\r\nAPI\r\n===\r\n\r\nSoučástí WebLoaderu jsou čtyři třídy: `CssLoader`, `JavaScriptLoader`, jejich abstraktní předek `WebLoader` a filtr `VariablesFilter`.\r\n\r\nWebLoader\r\n---------\r\n\r\n**Veřejné proměnné**\r\n\r\n|---------------------------------\r\n| název | význam | výchozí hodnota\r\n|---------------------------------\r\n| sourcePath | zdrojová složka, cesta na disku | |\r\n| sourceUri | zdrojová složka, adresa | |\r\n| tempPath | cílová složka, cesta na disku | |\r\n| tempUri | cílová složka, adresa | |\r\n| joinFiles | spojovat soubory do jednoho | `true`\r\n| generatedFileNamePrefix | prefix názvu generovaných souborů | `\"generated-\"`\r\n| filters | Pole filtrů. Filtry jsou libovolné callbacky, které berou jako parametr řetězec a vracejí také řetězec. | `array()`\r\n\r\n**Veřejné metody**\r\n\r\n|-------------------------------\r\n| název | význam | parametry | vrací\r\n|-------------------------------\r\n| getElement | *abstraktní* | `string` | `Nette\\Web\\Html` nebo `string`\r\n| render | renderuje komponentu | volitelně soubory k vygenerování | |\r\n| getFiles | získat pole soubor | | `array(string)`\r\n| addFile | přidat soubor pokud existuje | `string` | |\r\n| addFiles | přidat více souborů | `array(string)` | |\r\n| removeFile | odebrat soubor | `string` | |\r\n| removeFiles | odebrat více souborů | `array(string)` | |\r\n| clear | odebrat všechny soubory | |\r\n| getLastModified | datum změny nejnovějšího souboru | volitelně pole souborů, jinak zjištuje hodnotu z aktuálně přidaných souborů | `timestamp`\r\n| getGeneratedFilename | Název vygenerovaného souboru ze souborů. Hodnota závisí na názvu a času změny souborů. | volitelně pole souborů, jinak zjištuje hodnotu z aktuálně přidaných souborů | `string`\r\n| getContent | obsah vygenerovaného souboru | volitelně pole souborů, jinak zjištuje hodnotu z aktuálně přidaných souborů | `string`\r\n\r\nCssLoader\r\n---------\r\n\r\n**Veřejné proměnné**\r\n\r\n|---------------------------------\r\n| název | význam | výchozí hodnota\r\n|---------------------------------\r\n| media | obsah atributu media tagu link | |\r\n| absolutizeUrls | přepisovat hodnoty `url(...)` v CSS souborech na jejich absolutní formu | `true`\r\n\r\n**Veřejné metody**\r\n\r\n|-------------------------------\r\n| název | význam | parametry | vrací\r\n|-------------------------------\r\n| getElement | generuje tag link | hodnota atributu href | `Nette\\Web\\Html`\r\n| getGeneratedFilename | přepsaná metoda, přidává koncovku css | volitelně pole souborů, jinak zjištuje hodnotu z aktuálně přidaných souborů | `string`\r\n\r\nJavaScriptLoader\r\n----------------\r\n\r\n**Veřejné metody**\r\n\r\n|-------------------------------\r\n| název | význam | parametry | vrací\r\n|-------------------------------\r\n| getElement | generuje tag script | hodnota atributu src | `Nette\\Web\\Html`\r\n| getGeneratedFilename | přepsaná metoda, přidává koncovku js | volitelně pole souborů, jinak zjištuje hodnotu z aktuálně přidaných souborů | `string`\r\n\r\nVariablesFilter\r\n---------------\r\n\r\n**Veřejné metody**\r\n\r\n|-------------------------------\r\n| název | význam | parametry | vrací\r\n|-------------------------------\r\n| *konstruktor* | volitelně přijme asociativní pole `array(\'promenna\' => \'hodnota\')` | asociativní pole | |\r\n| setVariable | nastaví proměnnou | `string` název, `string` hodnota | |\r\n| setDelimiter | Nastaví tvar proměnných na *první parametr + název proměnné + druhý parametr*. Výchozí hodnoty jsou `{{$` a `}}` | `string` začátek proměnné, `string` ukončení proměnné | |\r\n| apply | provede náhradu proměnných | `string` | `string`\r\n',	'2012-04-14 14:43:21'),
(2,	'CurlExtension',	2,	'https://github.com/Kdyby/CurlExtension',	'',	'2012-04-14 14:45:52');

INSERT INTO `addon_dependency` (`id`, `addon_id`, `dependency_id`, `packageName`, `version`, `type`) VALUES
(1,	1,	NULL,	'nette/nette',	'2.0.x',	'require'),
(2,	3,	NULL,	'nette/nette',	'2.0.x',	'require'),
(3,	2,	NULL,	'nette/nette',	'0.9.7',	'require'),
(4,	4,	NULL,	'nette/nette',	'2.0.x',	'require');

INSERT INTO `addon_tag` (`addon_id`, `tag_id`) VALUES
(1,	1),
(2,	2);

INSERT INTO `addon_version` (`id`, `addon_id`, `version`) VALUES
(1,	1,	'2.0'),
(2,	1,	'1.7'),
(3,	2,	'1.0'),
(4,	1,	'2.0.1');

INSERT INTO `tag` (`id`, `name`, `slug`, `level`, `visible`) VALUES
(1,	'Assets',	'assets',	1,	1),
(2,	'cURL',	'curl',	1,	1);

INSERT INTO `user` (`id`, `name`, `password`, `email`) VALUES
(1,	'Merxes',	'6e017b5464f820a6c1bb5e9f6d711a667a80d8ea',	'me@gmail.com'),
(2,	'HosipLan',	'6e017b5464f820a6c1bb5e9f6d711a667a80d8ea',	'hosiplan@gmail.com'),
(3,	'Vrtak',	'6e017b5464f820a6c1bb5e9f6d711a667a80d8ea',	'vrtak@gmail.com'),
(4,	'Honza Marek',	'6e017b5464f820a6c1bb5e9f6d711a667a80d8ea',	'honza.marek@gmail.com'),
(5,	'Panda',	'6e017b5464f820a6c1bb5e9f6d711a667a80d8ea',	'panda@gmail.com'),
(6,	'chemiX',	'6e017b5464f820a6c1bb5e9f6d711a667a80d8ea',	'chemix@gmail.com'),
(7,	'dgx',	'6e017b5464f820a6c1bb5e9f6d711a667a80d8ea',	'dgx@gmail.com');

-- 2012-04-14 15:44:22
