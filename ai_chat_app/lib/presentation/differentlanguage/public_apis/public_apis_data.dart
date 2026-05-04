import 'package:flutter/material.dart';

/// ============================================================
/// Data models for Public APIs collection
/// Source: https://github.com/public-apis/public-apis
/// ============================================================

class PublicApi {
  final String name;
  final String url;
  final String description;
  final String auth;
  final bool https;
  final String cors;

  const PublicApi(this.name, this.url, this.description, this.auth, this.https, this.cors);

  String get authLabel {
    switch (auth) {
      case 'apiKey':
        return 'API Key';
      case 'OAuth':
        return 'OAuth';
      default:
        return '无需认证';
    }
  }

  Color get authColor {
    switch (auth) {
      case 'apiKey':
        return Colors.orange;
      case 'OAuth':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  IconData get authIcon {
    switch (auth) {
      case 'apiKey':
        return Icons.vpn_key;
      case 'OAuth':
        return Icons.lock;
      default:
        return Icons.public;
    }
  }
}

class PublicApisCategory {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final List<PublicApi> apis;

  const PublicApisCategory(this.name, this.icon, this.color, this.description, this.apis);
}

final List<PublicApisCategory> publicApisCategories = [
  PublicApisCategory(
    'Animals',
    Icons.pets,
    Color(0xFF43A047),
    '动物相关的API，包括猫狗图片、动物事实、鸟类观察、宠物领养等',
    [
      PublicApi('AdoptAPet', 'https://www.adoptapet.com/public/apis/pet_list.html', '帮助宠物领养的资源', 'apiKey', true, 'Yes'),
      PublicApi('Axolotl', 'https://theaxolotlapi.netlify.app/', '蝾螈图片和事实收集', 'No', true, 'No'),
      PublicApi('Cat Facts', 'https://alexwohlbruck.github.io/cat-facts/', '每日猫咪事实', 'No', true, 'No'),
      PublicApi('Cataas', 'https://cataas.com/', '猫即服务（猫咪图片和GIF）', 'No', true, 'No'),
      PublicApi('Cats', 'https://docs.thecatapi.com/', '来自Tumblr的猫咪图片', 'apiKey', true, 'No'),
      PublicApi('Dog Facts', 'https://kinduff.github.io/dog-api/', '随机狗狗事实', 'No', true, 'Yes'),
      PublicApi('Dogs', 'https://dog.ceo/dog-api/', '基于Stanford Dogs数据集', 'No', true, 'Yes'),
      PublicApi('eBird', 'https://documenter.getpostman.com/view/664302/S1ENwy59', '检索区域内近期或值得注意的鸟类观察数据', 'apiKey', true, 'No'),
      PublicApi('FishWatch', 'https://www.fishwatch.gov/developers', '鱼类物种信息和图片', 'No', true, 'Yes'),
      PublicApi('HTTP Cat', 'https://http.cat/', '每个HTTP状态码对应一只猫', 'No', true, 'Yes'),
      PublicApi('HTTP Dog', 'https://http.dog/', '每个HTTP状态码对应一只狗', 'No', true, 'Yes'),
      PublicApi('IUCN', 'http://apiv3.iucnredlist.org/api/v3/docs', 'IUCN濒危物种红色名录', 'apiKey', false, 'No'),
      PublicApi('MeowFacts', 'https://github.com/wh-iterabb-it/meowfacts', '获取随机猫咪事实', 'No', true, 'No'),
      PublicApi('Petfinder', 'https://www.petfinder.com/developers/', '帮助宠物找到家园', 'apiKey', true, 'Yes'),
      PublicApi('PlaceDog', 'https://place.dog', '占位狗狗图片', 'No', true, 'Yes'),
      PublicApi('PlaceKitten', 'https://placekitten.com/', '占位猫咪图片', 'No', true, 'Yes'),
      PublicApi('RandomDog', 'https://random.dog/woof.json', '随机狗狗图片', 'No', true, 'Yes'),
      PublicApi('RandomDuck', 'https://random-d.uk/api', '随机鸭子图片', 'No', true, 'No'),
      PublicApi('RandomFox', 'https://randomfox.ca/floof/', '随机狐狸图片', 'No', true, 'No'),
      PublicApi('Shibe.Online', 'http://shibe.online/', '随机柴犬、猫或鸟的图片', 'No', true, 'Yes'),
      PublicApi('The Dog', 'https://thedogapi.com/', '关于狗狗的公共服务，免费用于应用和网站', 'apiKey', true, 'No'),
      PublicApi('xeno-canto', 'https://xeno-canto.org/explore/api', '鸟类录音', 'No', true, 'Unknown'),
      PublicApi('Zoo Animals', 'https://zoo-animal-api.herokuapp.com/', '动物园动物的事实和图片', 'No', true, 'Yes'),
    ],
  ),

  PublicApisCategory(
    'Anime',
    Icons.animation,
    Color(0xFFE91E63),
    '动漫相关的API，包括动漫数据库、图片、引用和追踪',
    [
      PublicApi('AniList', 'https://github.com/AniList/ApiV2-GraphQL-Docs', '动漫发现与追踪', 'OAuth', true, 'Unknown'),
      PublicApi('AnimeChan', 'https://github.com/RocktimSaikia/anime-chan', '动漫引用（10000+条）', 'No', true, 'No'),
      PublicApi('AnimeNewsNetwork', 'https://www.animenewsnetwork.com/encyclopedia/api.php', '动漫行业新闻', 'No', true, 'Yes'),
      PublicApi('Jikan', 'https://jikan.moe', '非官方MyAnimeList API', 'No', true, 'Yes'),
      PublicApi('Kitsu', 'https://kitsu.docs.apiary.io/', '动漫发现平台', 'OAuth', true, 'Yes'),
      PublicApi('MangaDex', 'https://api.mangadex.org/docs.html', '漫画数据库和社区', 'apiKey', true, 'Unknown'),
      PublicApi('MyAnimeList', 'https://myanimelist.net/clubs.php?cid=13727', '动漫和漫画数据库与社区', 'OAuth', true, 'Unknown'),
      PublicApi('NekosBest', 'https://docs.nekos.best', 'Neko图片和动漫角色扮演GIF', 'No', true, 'Yes'),
      PublicApi('Shikimori', 'https://shikimori.one/api/doc', '动漫发现、追踪、论坛、评分', 'OAuth', true, 'Unknown'),
      PublicApi('Studio Ghibli', 'https://ghibliapi.herokuapp.com', '吉卜力工作室电影资源', 'No', true, 'Yes'),
      PublicApi('Trace Moe', 'https://soruly.github.io/trace.moe-api/#/', '从截图找到确切的动漫场景', 'No', true, 'No'),
      PublicApi('Waifu.im', 'https://waifu.im/docs', '从4000+图片档案中获取waifu图片', 'No', true, 'Yes'),
      PublicApi('Waifu.pics', 'https://waifu.pics/docs', '动漫图片分享平台', 'No', true, 'No'),
    ],
  ),

  PublicApisCategory(
    'Books',
    Icons.menu_book,
    Color(0xFF795548),
    '图书相关API，包括书籍搜索、图书馆数据、诗歌、宗教经典等',
    [
      PublicApi('Bible-api', 'https://bible-api.com/', '多语言免费圣经API', 'No', true, 'Yes'),
      PublicApi('Google Books', 'https://developers.google.com/books/', '图书搜索', 'OAuth', true, 'Unknown'),
      PublicApi('Gutendex', 'https://gutendex.com/', '古腾堡计划图书库Web API', 'No', true, 'Unknown'),
      PublicApi('Open Library', 'https://openlibrary.org/developers/api', '图书、封面和相关数据', 'No', true, 'No'),
      PublicApi('Penguin Publishing', 'http://www.penguinrandomhouse.biz/webservices/rest/', '图书、封面和相关数据', 'No', true, 'Yes'),
      PublicApi('PoetryDB', 'https://github.com/thundercomb/poetrydb#readme', '从海量诗歌收藏中获取即时数据', 'No', true, 'Yes'),
      PublicApi('Quran', 'https://quran.api-docs.io/', '多语言RESTful古兰经API', 'No', true, 'Yes'),
      PublicApi('Quran Cloud', 'https://alquran.cloud/api', 'RESTful古兰经API', 'No', true, 'Yes'),
      PublicApi('Rig Veda', 'https://aninditabasu.github.io/indica/html/rv.html', '吠陀文献中的神、诗人、韵律', 'No', true, 'Unknown'),
      PublicApi('The Bible', 'https://docs.api.bible', '一站式圣经内容', 'apiKey', true, 'Unknown'),
      PublicApi('Thirukkural', 'https://api-thirukkural.web.app/', '1330首Thirukkural诗歌及解释', 'No', true, 'Yes'),
      PublicApi('Wizard World', 'https://wizard-world-api.herokuapp.com/swagger/index.html', '哈利波特宇宙信息', 'No', true, 'Yes'),
      PublicApi('Wolne Lektury', 'https://wolnelektury.pl/api/', 'WolneLektury.pl电子书信息API', 'No', true, 'Unknown'),
    ],
  ),

  PublicApisCategory(
    'Calendar',
    Icons.calendar_today,
    Color(0xFF0288D1),
    '日历和节假日相关API，包括全球节假日、日历事件、命名日等',
    [
      PublicApi('Calendarific', 'https://calendarific.com/', '全球节假日', 'apiKey', true, 'Unknown'),
      PublicApi('Church Calendar', 'http://calapi.inadiutorium.cz/', '天主教礼仪日历', 'No', false, 'Unknown'),
      PublicApi('Czech Namedays Calendar', 'https://svatky.adresa.info', '查找姓名并返回命名日日期', 'No', false, 'Unknown'),
      PublicApi('Google Calendar', 'https://developers.google.com/google-apps/calendar/', '显示、创建和修改Google日历事件', 'OAuth', true, 'Unknown'),
      PublicApi('Hebrew Calendar', 'https://www.hebcal.com/home/developer-apis', '公历与希伯来历转换，获取安息日时间', 'No', false, 'Unknown'),
      PublicApi('Holidays', 'https://holidayapi.com/', '节假日历史数据', 'apiKey', true, 'Unknown'),
      PublicApi('Nager.Date', 'https://date.nager.at', '90+国家公共节假日', 'No', true, 'No'),
      PublicApi('Namedays Calendar', 'https://nameday.abalin.net', '多国命名日', 'No', true, 'Yes'),
      PublicApi('Non-Working Days', 'https://isdayoff.ru', '查询工作日/非工作日的简单REST API', 'No', true, 'Yes'),
      PublicApi('UK Bank Holidays', 'https://www.gov.uk/bank-holidays.json', '英国银行假日', 'No', true, 'Unknown'),
    ],
  ),

  PublicApisCategory(
    'Business',
    Icons.business,
    Color(0xFF1565C0),
    '商业相关API，包括邮件营销、分析、支付、项目管理等',
    [
      PublicApi('Apache Superset', 'https://superset.apache.org/docs/api', '管理BI仪表板和数据源的API', 'apiKey', true, 'Yes'),
      PublicApi('Charity Search', 'http://charityapi.orghunter.com/', '非营利慈善组织数据', 'apiKey', false, 'Unknown'),
      PublicApi('Clearbit Logo', 'https://clearbit.com/docs#logo-api', '搜索公司Logo并嵌入项目', 'apiKey', true, 'Unknown'),
      PublicApi('Domainsdb.info', 'https://domainsdb.info/', '已注册域名搜索', 'No', true, 'No'),
      PublicApi('Gmail', 'https://developers.google.com/gmail/api/', '灵活的RESTful访问用户收件箱', 'OAuth', true, 'Unknown'),
      PublicApi('Google Analytics', 'https://developers.google.com/analytics/', '收集和分析数据', 'OAuth', true, 'Unknown'),
      PublicApi('Mailchimp', 'https://mailchimp.com/developer/', '发送营销邮件和事务性邮件', 'apiKey', true, 'Unknown'),
      PublicApi('Redash', 'https://redash.io/help/user-guide/integrations-and-api/api', '访问Redash上的查询和仪表板', 'apiKey', true, 'Yes'),
      PublicApi('Smartsheet', 'https://smartsheet.redoc.ly/', '编程访问Smartsheet数据和账户', 'OAuth', true, 'No'),
      PublicApi('Square', 'https://developer.squareup.com/reference/square', '收付款、管理退款', 'OAuth', true, 'Unknown'),
      PublicApi('Trello', 'https://developers.trello.com/', '看板、列表和卡片管理', 'OAuth', true, 'Unknown'),
      PublicApi('Tomba email finder', 'https://tomba.io/api', 'B2B销售邮件查找器和验证器', 'apiKey', true, 'Yes'),
    ],
  ),

  PublicApisCategory(
    'Cloud Storage & File Sharing',
    Icons.cloud,
    Color(0xFF00897B),
    '云存储和文件分享API',
    [
      PublicApi('Box', 'https://developer.box.com/', '文件分享和存储', 'OAuth', true, 'Unknown'),
      PublicApi('Dropbox', 'https://www.dropbox.com/developers', '文件分享和存储', 'OAuth', true, 'Unknown'),
      PublicApi('File.io', 'https://www.file.io', '超简单文件分享，匿名安全', 'No', true, 'Unknown'),
      PublicApi('Google Drive', 'https://developers.google.com/drive/', '文件分享和存储', 'OAuth', true, 'Unknown'),
      PublicApi('Gyazo', 'https://gyazo.com/api/docs', '即时保存和分享屏幕截图', 'apiKey', true, 'Unknown'),
      PublicApi('Imgbb', 'https://api.imgbb.com/', '简单快速的私人图片分享', 'apiKey', true, 'Unknown'),
      PublicApi('OneDrive', 'https://developer.microsoft.com/onedrive', '文件分享和存储', 'OAuth', true, 'Unknown'),
      PublicApi('Pantry', 'https://getpantry.cloud/', '小型项目免费JSON存储', 'No', true, 'Yes'),
      PublicApi('Pastebin', 'https://pastebin.com/doc_api', '纯文本存储', 'apiKey', true, 'Unknown'),
      PublicApi('Pinata', 'https://docs.pinata.cloud/', 'IPFS固定服务API', 'apiKey', true, 'Unknown'),
      PublicApi('Storj', 'https://docs.storj.io/dcs/', '去中心化开源云存储', 'apiKey', true, 'Unknown'),
      PublicApi('Web3 Storage', 'https://web3.storage/', '免费文件分享和存储（1TB空间）', 'apiKey', true, 'Yes'),
    ],
  ),

  PublicApisCategory(
    'Cryptocurrency',
    Icons.currency_bitcoin,
    Color(0xFFF7931A),
    '加密货币相关API，包括交易所、行情、区块链数据等',
    [
      PublicApi('Binance', 'https://github.com/binance/binance-spot-api-docs', '加密货币交易所', 'apiKey', true, 'Unknown'),
      PublicApi('Blockchain', 'https://www.blockchain.com/api', '比特币支付、钱包和交易数据', 'apiKey', true, 'Unknown'),
      PublicApi('CoinAPI', 'https://docs.coinapi.io/', '统一API集成所有货币交易所', 'apiKey', true, 'No'),
      PublicApi('Coinbase', 'https://developers.coinbase.com', '比特币、以太坊等价格', 'apiKey', true, 'Unknown'),
      PublicApi('CoinCap', 'https://docs.coincap.io/', '实时加密货币价格RESTful API', 'No', true, 'Unknown'),
      PublicApi('CoinDesk', 'https://old.coindesk.com/coindesk-api/', 'CoinDesk比特币价格指数', 'No', true, 'Unknown'),
      PublicApi('CoinGecko', 'http://www.coingecko.com/api', '加密货币价格、市场和开发者数据', 'No', true, 'Yes'),
      PublicApi('CoinMarketCap', 'https://coinmarketcap.com/api/', '加密货币价格', 'apiKey', true, 'Unknown'),
      PublicApi('Coinpaprika', 'https://api.coinpaprika.com', '加密货币价格、交易量等', 'No', true, 'Yes'),
      PublicApi('CoinStats', 'https://documenter.getpostman.com/view/5734027/RzZ6Hzr3?version=latest', '加密货币追踪器', 'No', true, 'Unknown'),
      PublicApi('CryptoCompare', 'https://www.cryptocompare.com/api#', '加密货币比较', 'No', true, 'Unknown'),
      PublicApi('Etherscan', 'https://etherscan.io/apis', '以太坊浏览器API', 'apiKey', true, 'Yes'),
      PublicApi('Gemini', 'https://docs.gemini.com/rest-api/', '加密货币交易所', 'No', true, 'Unknown'),
      PublicApi('INFURA Ethereum', 'https://infura.io/product/ethereum', '与以太坊主网和测试网交互', 'apiKey', true, 'Yes'),
      PublicApi('Kraken', 'https://docs.kraken.com/rest/', '加密货币交易所', 'apiKey', true, 'Unknown'),
      PublicApi('KuCoin', 'https://docs.kucoin.com/', '加密货币交易平台', 'apiKey', true, 'Unknown'),
      PublicApi('Localbitcoins', 'https://localbitcoins.com/api-docs/', 'P2P比特币买卖平台', 'No', true, 'Unknown'),
      PublicApi('Messari', 'https://messari.io/api', '数千种加密资产的API端点', 'No', true, 'Unknown'),
      PublicApi('Nomics', 'https://nomics.com/docs/', '历史和实时加密货币价格数据', 'apiKey', true, 'Yes'),
      PublicApi('Solana JSON RPC', 'https://docs.solana.com/developing/clients/jsonrpc-api', '与Solana区块链交互', 'No', true, 'Unknown'),
    ],
  ),

  PublicApisCategory(
    'Currency Exchange',
    Icons.currency_exchange,
    Color(0xFF4CAF50),
    '货币汇率API，支持150+货币的实时和历史汇率',
    [
      PublicApi('1Forge', 'https://1forge.com/forex-data-api/api-documentation', '外汇市场数据', 'apiKey', true, 'Unknown'),
      PublicApi('Currency-api', 'https://github.com/fawazahmed0/currency-api#readme', '免费汇率API，150+货币，无速率限制', 'No', true, 'Yes'),
      PublicApi('CurrencyFreaks', 'https://currencyfreaks.com/', '当前和历史汇率，免费1000请求/月', 'apiKey', true, 'Yes'),
      PublicApi('Currencylayer', 'https://currencylayer.com', '汇率和货币转换', 'apiKey', true, 'Unknown'),
      PublicApi('CurrencyScoop', 'https://currencyscoop.com/api-documentation', '实时和历史汇率JSON API', 'apiKey', true, 'Yes'),
      PublicApi('Exchangerate.host', 'https://exchangerate.host', '免费外汇和加密货币汇率API', 'No', true, 'Unknown'),
      PublicApi('Exchangeratesapi.io', 'https://exchangeratesapi.io', '汇率与货币转换', 'apiKey', true, 'Yes'),
      PublicApi('Fixer', 'https://fixer.io', '汇率和货币转换', 'apiKey', false, 'Unknown'),
      PublicApi('Frankfurter', 'https://www.frankfurter.app/docs', '汇率、货币转换和时间序列', 'No', true, 'Yes'),
      PublicApi('FreeForexAPI', 'https://freeforexapi.com/Home/Api', '主要货币对实时汇率', 'No', true, 'No'),
    ],
  ),

  PublicApisCategory(
    'Development',
    Icons.code,
    Color(0xFF37474F),
    '开发者工具API，包括代码托管、测试、截图、域名查询、IP工具等',
    [
      PublicApi('Agify.io', 'https://agify.io', '根据名字估算年龄', 'No', true, 'Yes'),
      PublicApi('APIs.guru', 'https://apis.guru/api-doc/', '公共API的Wikipedia', 'No', true, 'Unknown'),
      PublicApi('Azure DevOps', 'https://docs.microsoft.com/en-us/rest/api/azure/devops', 'Azure DevOps REST API', 'apiKey', true, 'Unknown'),
      PublicApi('Bitbucket', 'https://developer.atlassian.com/bitbucket/api/2/reference/', 'Bitbucket API', 'OAuth', true, 'Unknown'),
      PublicApi('Bored', 'https://www.boredapi.com/', '寻找随机活动打发无聊', 'No', true, 'Unknown'),
      PublicApi('CDNJS', 'https://api.cdnjs.com/libraries/jquery', 'CDNJS库信息', 'No', true, 'Unknown'),
      PublicApi('CountAPI', 'https://countapi.xyz', '免费简单计数服务', 'No', true, 'Yes'),
      PublicApi('DigitalOcean Status', 'https://status.digitalocean.com/api', 'DigitalOcean服务状态', 'No', true, 'Unknown'),
      PublicApi('Docker Hub', 'https://docs.docker.com/docker-hub/api/latest/', '与Docker Hub交互', 'apiKey', true, 'Yes'),
      PublicApi('Genderize.io', 'https://genderize.io', '根据名字估算性别', 'No', true, 'Yes'),
      PublicApi('GitHub', 'https://docs.github.com/en/free-pro-team@latest/rest', 'GitHub仓库、代码和用户信息', 'OAuth', true, 'Yes'),
      PublicApi('Gitlab', 'https://docs.gitlab.com/ee/api/', 'GitLab交互自动化', 'OAuth', true, 'Unknown'),
      PublicApi('Google Fonts', 'https://developers.google.com/fonts/docs/developer_api', 'Google Fonts元数据', 'apiKey', true, 'Unknown'),
      PublicApi('Heroku', 'https://devcenter.heroku.com/articles/platform-api-reference/', '编程管理Heroku应用', 'OAuth', true, 'Yes'),
      PublicApi('Httpbin', 'https://httpbin.org/', '简单HTTP请求与响应服务', 'No', true, 'Yes'),
      PublicApi('IPify', 'https://www.ipify.org/', '简单IP地址API', 'No', true, 'Unknown'),
      PublicApi('IPinfo', 'https://ipinfo.io/developers', 'IP地址信息', 'No', true, 'Unknown'),
      PublicApi('JSONbin.io', 'https://jsonbin.io', '免费JSON存储服务', 'apiKey', true, 'Yes'),
      PublicApi('MAC address vendor lookup', 'https://macaddress.io/api', 'MAC地址厂商查询', 'apiKey', true, 'Yes'),
      PublicApi('Mocky', 'https://designer.mocky.io/', '模拟REST API端点', 'No', true, 'Yes'),
      PublicApi('Nationalize.io', 'https://nationalize.io', '根据名字估算国籍', 'No', true, 'Yes'),
      PublicApi('Netlify', 'https://docs.netlify.com/api/get-started/', 'Netlify API', 'OAuth', true, 'Unknown'),
      PublicApi('NetworkCalc', 'https://networkcalc.com/api/docs', '网络计算器API', 'No', true, 'Yes'),
      PublicApi('npm Registry', 'https://github.com/npm/registry/blob/master/docs/REGISTRY-API.md', '查询Node.js库信息', 'No', true, 'Unknown'),
      PublicApi('Postman', 'https://www.postman.com/postman/workspace/postman-public-workspace/documentation/12959542-c8142d51-e97c-46b6-bd77-52bb66712c9a', 'API测试工具', 'apiKey', true, 'Unknown'),
      PublicApi('QuickChart', 'https://quickchart.io/', '生成图表和图形图片', 'No', true, 'Yes'),
      PublicApi('ReqRes', 'https://reqres.in/', '托管REST-API用于测试', 'No', true, 'Unknown'),
      PublicApi('ScraperApi', 'https://www.scraperapi.com', '轻松构建可扩展的网页爬虫', 'apiKey', true, 'Unknown'),
      PublicApi('ScreenshotAPI.net', 'https://screenshotapi.net/', '创建完美像素的网站截图', 'apiKey', true, 'Yes'),
      PublicApi('serpstack', 'https://serpstack.com/', '实时准确的Google搜索结果API', 'apiKey', true, 'Yes'),
      PublicApi('StackExchange', 'https://api.stackexchange.com/', '开发者问答论坛', 'OAuth', true, 'Unknown'),
      PublicApi('ZenRows', 'https://www.zenrows.com/', '绕过反爬的Web Scraping API', 'apiKey', true, 'Unknown'),
    ],
  ),

  PublicApisCategory(
    'Email',
    Icons.email,
    Color(0xFF5C6BC0),
    '邮件相关API，包括邮件验证、临时邮箱、邮件发送等',
    [
      PublicApi('Disify', 'https://www.disify.com/', '检测一次性临时邮箱地址', 'No', true, 'Yes'),
      PublicApi('DropMail', 'https://dropmail.me/api/#live-demo', '创建和管理临时邮箱的GraphQL API', 'No', true, 'Unknown'),
      PublicApi('EVA', 'https://eva.pingutil.com/', '验证邮箱地址', 'No', true, 'Yes'),
      PublicApi('Guerrilla Mail', 'https://www.guerrillamail.com/GuerrillaMailAPI.html', '一次性临时邮箱地址', 'No', true, 'Unknown'),
      PublicApi('ImprovMX', 'https://improvmx.com/api', '免费邮件转发服务API', 'apiKey', true, 'Unknown'),
      PublicApi('Kickbox', 'https://open.kickbox.com/', '邮箱验证API', 'No', true, 'Yes'),
      PublicApi('MailboxValidator', 'https://www.mailboxvalidator.com/api-email-free', '验证邮箱提高送达率', 'apiKey', true, 'Unknown'),
      PublicApi('MailCheck.ai', 'https://www.mailcheck.ai/#documentation', '防止用户使用临时邮箱注册', 'No', true, 'Unknown'),
      PublicApi('Mailtrap', 'https://mailtrap.docs.apiary.io/#', '安全测试邮件的服务', 'apiKey', true, 'Unknown'),
      PublicApi('Sendgrid', 'https://docs.sendgrid.com/api-reference/', '云端SMTP邮件发送服务', 'apiKey', true, 'Unknown'),
      PublicApi('Sendinblue', 'https://developers.sendinblue.com/docs', '营销和事务性邮件/SMS服务', 'apiKey', true, 'Unknown'),
      PublicApi('Verifier', 'https://verifier.meetchopra.com/docs#/', '验证邮箱是否真实', 'apiKey', true, 'Yes'),
    ],
  ),

  PublicApisCategory(
    'Entertainment',
    Icons.movie,
    Color(0xFFFF5722),
    '娱乐相关API，包括笑话、梗图、趣事等',
    [
      PublicApi('chucknorris.io', 'https://api.chucknorris.io', '精心挑选的Chuck Norris笑话JSON API', 'No', true, 'Unknown'),
      PublicApi('Corporate Buzz Words', 'https://github.com/sameerkumar18/corporate-bs-generator-api', '企业流行语REST API', 'No', true, 'Yes'),
      PublicApi('Excuser', 'https://excuser.herokuapp.com/', '获取各种情景的随机借口', 'No', true, 'Unknown'),
      PublicApi('Fun Fact', 'https://api.aakhilv.me', '随机返回一个趣事', 'No', true, 'Yes'),
      PublicApi('Imgflip', 'https://imgflip.com/api', '获取热门梗图', 'No', true, 'Unknown'),
      PublicApi('Meme Maker', 'https://mememaker.github.io/API/', '创建自定义梗图的REST API', 'No', true, 'Unknown'),
      PublicApi('Random Useless Facts', 'https://uselessfacts.jsph.pl/', '获取无用但真实的事实', 'No', true, 'Unknown'),
      PublicApi('Techy', 'https://techy-api.vercel.app/', '技术相关的短语JSON/Plaintext API', 'No', true, 'Unknown'),
      PublicApi('Yo Momma Jokes', 'https://github.com/beanboi7/yomomma-apiv2', 'Yo Momma笑话REST API', 'No', true, 'Unknown'),
    ],
  ),

  PublicApisCategory(
    'Food & Drink',
    Icons.restaurant,
    Color(0xFFE64A19),
    '餐饮相关API，包括食谱、营养、啤酒、鸡尾酒等',
    [
      PublicApi('BaconMockup', 'https://baconmockup.com/', '可调整大小的培根占位图片', 'No', true, 'Yes'),
      PublicApi('Coffee', 'https://coffee.alexflipnote.dev/', '随机咖啡图片', 'No', true, 'Unknown'),
      PublicApi('Edamam nutrition', 'https://developer.edamam.com/edamam-docs-nutrition-api', '营养分析', 'apiKey', true, 'Unknown'),
      PublicApi('Edamam recipes', 'https://developer.edamam.com/edamam-docs-recipe-api', '食谱搜索', 'apiKey', true, 'Unknown'),
      PublicApi('Foodish', 'https://github.com/surhud004/Foodish#readme', '随机食物图片', 'No', true, 'Yes'),
      PublicApi('Fruityvice', 'https://www.fruityvice.com', '各类水果的数据', 'No', true, 'Unknown'),
      PublicApi('Open Brewery DB', 'https://www.openbrewerydb.org', '啤酒厂和精酿啤酒数据', 'No', true, 'Yes'),
      PublicApi('Open Food Facts', 'https://world.openfoodfacts.org/data', '食品产品数据库', 'No', true, 'Unknown'),
      PublicApi('PunkAPI', 'https://punkapi.com/', 'Brewdog啤酒配方', 'No', true, 'Unknown'),
      PublicApi('Spoonacular', 'https://spoonacular.com/food-api', '食谱、食品和餐食计划', 'apiKey', true, 'Unknown'),
      PublicApi('TacoFancy', 'https://github.com/evz/tacofancy-api', '社区驱动的墨西哥卷饼数据库', 'No', false, 'Unknown'),
      PublicApi('TheCocktailDB', 'https://www.thecocktaildb.com/api.php', '鸡尾酒配方', 'apiKey', true, 'Yes'),
      PublicApi('TheMealDB', 'https://www.themealdb.com/api.php', '餐食配方', 'apiKey', true, 'Yes'),
      PublicApi('Untappd', 'https://untappd.com/api/docs', '社交啤酒分享', 'OAuth', true, 'Unknown'),
      PublicApi('Zestful', 'https://zestfuldata.com/', '解析食谱原料', 'apiKey', true, 'Yes'),
    ],
  ),

  PublicApisCategory(
    'Games & Comics',
    Icons.sports_esports,
    Color(0xFF7B1FA2),
    '游戏和漫画API，包括宝可梦、游戏数据、卡牌、漫画等',
    [
      PublicApi('AmiiboAPI', 'https://amiiboapi.com/', '任天堂Amiibo信息', 'No', true, 'Yes'),
      PublicApi('Battle.net', 'https://develop.battle.net/documentation/guides/getting-started', '暴雪游戏数据API', 'OAuth', true, 'Yes'),
      PublicApi('Board Game Geek', 'https://boardgamegeek.com/wiki/page/BGG_XML_API2', '桌游、RPG和电子游戏', 'No', true, 'No'),
      PublicApi('CheapShark', 'https://www.cheapshark.com/api', 'Steam/PC游戏价格和优惠', 'No', true, 'Yes'),
      PublicApi('Chess.com', 'https://www.chess.com/news/view/published-data-api', 'Chess.com只读REST API', 'No', true, 'Unknown'),
      PublicApi('Deck of Cards', 'http://deckofcardsapi.com/', '扑克牌API', 'No', false, 'Unknown'),
      PublicApi('Dota 2', 'https://docs.opendota.com/', 'Dota 2玩家统计、比赛数据', 'apiKey', true, 'Unknown'),
      PublicApi('Dungeons and Dragons', 'https://www.dnd5eapi.co/docs/', 'D&D 5版法术、职业、怪物参考', 'No', false, 'No'),
      PublicApi('Fortnite', 'https://fortnitetracker.com/site-api', 'Fortnite统计', 'apiKey', true, 'Unknown'),
      PublicApi('FreeToGame', 'https://www.freetogame.com/api-doc', '免费游戏数据库', 'No', true, 'Yes'),
      PublicApi('Giant Bomb', 'https://www.giantbomb.com/api/documentation', '电子游戏数据', 'apiKey', true, 'Unknown'),
      PublicApi('Guild Wars 2', 'https://wiki.guildwars2.com/wiki/API:Main', '激战2游戏信息', 'apiKey', true, 'Unknown'),
      PublicApi('Hearthstone', 'http://hearthstoneapi.com/', '炉石传说卡牌信息', 'apiKey', true, 'Unknown'),
      PublicApi('IGDB.com', 'https://api-docs.igdb.com', '视频游戏数据库', 'apiKey', true, 'Unknown'),
      PublicApi('JokeAPI', 'https://sv443.net/jokeapi/v2/', '编程、杂项和黑色幽默笑话', 'No', true, 'Yes'),
      PublicApi('Lichess', 'https://lichess.org/api', 'Lichess用户、游戏、谜题数据', 'OAuth', true, 'Unknown'),
      PublicApi('Magic The Gathering', 'http://magicthegathering.io/', '万智牌游戏信息', 'No', false, 'Unknown'),
      PublicApi('Marvel', 'https://developer.marvel.com', '漫威漫画', 'apiKey', true, 'Unknown'),
      PublicApi('Open Trivia', 'https://opentdb.com/api_config.php', '趣味问答题目', 'No', true, 'Unknown'),
      PublicApi('Pokéapi', 'https://pokeapi.co', '宝可梦信息', 'No', true, 'Unknown'),
      PublicApi('Pokémon TCG', 'https://pokemontcg.io', '宝可梦卡牌信息', 'No', true, 'Unknown'),
      PublicApi('RAWG.io', 'https://rawg.io/apidocs', '50万+游戏，50+平台', 'apiKey', true, 'Unknown'),
      PublicApi('Rick and Morty', 'https://rickandmortyapi.com', 'Rick and Morty所有信息', 'No', true, 'Yes'),
      PublicApi('Riot Games', 'https://developer.riotgames.com/', '英雄联盟游戏信息', 'apiKey', true, 'Unknown'),
      PublicApi('Scryfall', 'https://scryfall.com/docs/api', '万智牌数据库', 'No', true, 'Yes'),
      PublicApi('Steam', 'https://steamapi.xpaw.me/', 'Steam Web API文档', 'apiKey', true, 'No'),
      PublicApi('SuperHeroes', 'https://superheroapi.com', '所有超级英雄和反派数据', 'apiKey', true, 'Unknown'),
      PublicApi('xkcd', 'https://xkcd.com/json.html', '以JSON获取xkcd漫画', 'No', true, 'No'),
      PublicApi('Yu-Gi-Oh!', 'https://db.ygoprodeck.com/api-guide/', '游戏王卡牌信息', 'No', true, 'Unknown'),
    ],
  ),

  PublicApisCategory(
    'Geocoding',
    Icons.map,
    Color(0xFF33691E),
    '地理编码和地图API，包括IP定位、地址解析、地图服务等',
    [
      PublicApi('Bing Maps', 'https://www.microsoft.com/maps/', '基于Bing Maps创建数字地图', 'apiKey', true, 'Unknown'),
      PublicApi('Cartes.io', 'https://github.com/M-Media-Group/Cartes.io/wiki/API', '创建地图和标记', 'No', true, 'Unknown'),
      PublicApi('Country', 'http://country.is/', '根据IP获取访客国家', 'No', true, 'Yes'),
      PublicApi('CountryStateCity', 'https://countrystatecity.in/', '世界国家、州、城市数据', 'apiKey', true, 'Yes'),
      PublicApi('Geoapify', 'https://www.geoapify.com/api/geocoding-api/', '正反向地理编码，地址自动完成', 'apiKey', true, 'Yes'),
      PublicApi('Geocode.xyz', 'https://geocode.xyz/api', '全球正反向地理编码', 'No', true, 'Unknown'),
      PublicApi('GeoDB Cities', 'http://geodb-cities-api.wirefreethought.com/', '全球城市、地区和国家数据', 'apiKey', true, 'Unknown'),
      PublicApi('GeoJS', 'https://www.geojs.io/', 'IP地理定位', 'No', true, 'Yes'),
      PublicApi('GeoNames', 'http://www.geonames.org/export/web-services.html', '地名和其他地理数据', 'No', false, 'Unknown'),
      PublicApi('Google Maps', 'https://developers.google.com/maps/', '基于Google Maps创建数字地图', 'apiKey', true, 'Unknown'),
      PublicApi('HERE Maps', 'https://developer.here.com', '基于HERE Maps创建数字地图', 'apiKey', true, 'Unknown'),
      PublicApi('ip-api', 'https://ip-api.com/docs', '通过IP地址或域名查找位置', 'No', false, 'Unknown'),
      PublicApi('IP2Location', 'https://www.ip2location.com/web-service/ip2location', 'IP地理定位Web服务', 'apiKey', true, 'Unknown'),
      PublicApi('ipapi.co', 'https://ipapi.co/api/#introduction', '查找IP地址位置信息', 'No', true, 'Yes'),
      PublicApi('ipgeolocation', 'https://ipgeolocation.io/', 'IP地理定位API', 'apiKey', true, 'Yes'),
      PublicApi('LocationIQ', 'https://locationiq.org/docs/', '正反向地理编码和批量地理编码', 'apiKey', true, 'Yes'),
      PublicApi('Mapbox', 'https://docs.mapbox.com/', '创建/定制精美的数字地图', 'apiKey', true, 'Unknown'),
      PublicApi('MapQuest', 'https://developer.mapquest.com/', '访问地图世界的工具和资源', 'apiKey', true, 'No'),
      PublicApi('Nominatim', 'https://nominatim.org/release-docs/latest/api/Overview/', '全球正反向地理编码', 'No', true, 'Yes'),
    ],
  ),

  PublicApisCategory(
    'Machine Learning',
    Icons.psychology,
    Color(0xFF0D47A1),
    '机器学习和AI相关API，包括NLP、图像识别、语音处理等',
    [
      PublicApi('AI For Thai', 'https://aiforthai.in.th/api.php', '泰语NLP API服务', 'apiKey', true, 'Yes'),
      PublicApi('Clarifai', 'https://docs.clarifai.com', '计算机视觉', 'OAuth', true, 'Unknown'),
      PublicApi('Deepcode', 'https://www.deepcode.ai', 'AI代码审查', 'No', true, 'Unknown'),
      PublicApi('Dialogflow', 'https://cloud.google.com/dialogflow/docs', '自然语言处理', 'apiKey', true, 'Unknown'),
      PublicApi('EXUDE-API', 'https://exude-api.herokuapp.com', '分析文本情感', 'No', true, 'Yes'),
      PublicApi('Hirak Face Detection', 'https://faceapi.hirak.site/', '人脸检测API', 'apiKey', true, 'Unknown'),
      PublicApi('Imagga', 'https://imagga.com/', '自动图像标记', 'apiKey', true, 'Unknown'),
      PublicApi('Inferdo', 'https://rapidapi.com/user/inferdo', '计算机视觉服务', 'apiKey', true, 'Unknown'),
      PublicApi('IPS Online', 'https://docs.identity.ps/docs', '人脸和身份证验证', 'apiKey', true, 'Unknown'),
      PublicApi('Keenious', 'https://keenious.com/api', '文档搜索分析', 'apiKey', true, 'Unknown'),
      PublicApi('NLP Cloud', 'https://nlpcloud.io', '生产就绪NLP API', 'apiKey', true, 'Unknown'),
      PublicApi('OpenAI', 'https://beta.openai.com/docs', 'GPT-3、DALL-E等AI模型', 'apiKey', true, 'Unknown'),
      PublicApi('Perspective', 'https://perspectiveapi.com', 'NLP API过滤有害内容', 'apiKey', true, 'Unknown'),
      PublicApi('Roboflow Universe', 'https://universe.roboflow.com', '预训练计算机视觉模型', 'apiKey', true, 'Unknown'),
      PublicApi('SkyBiometry', 'https://skybiometry.com/documentation/', '人脸检测和识别', 'apiKey', true, 'Unknown'),
      PublicApi('Time Door', 'https://timedoor.io', '时间序列分析API', 'apiKey', true, 'Yes'),
      PublicApi('Unplugg', 'https://unplu.gg/test_api.html', '时间序列预测自动化API', 'apiKey', true, 'Unknown'),
      PublicApi('WolframAlpha', 'https://products.wolframalpha.com/api/', '计算智能', 'apiKey', true, 'Unknown'),
    ],
  ),

  PublicApisCategory(
    'Music',
    Icons.music_note,
    Color(0xFF311B92),
    '音乐相关API，包括歌词、音乐识别、音频分析等',
    [
      PublicApi('7digital', 'https://docs.7digital.com/reference', '音乐推荐和购买平台', 'OAuth', true, 'Unknown'),
      PublicApi('AI Mastering', 'https://aimastering.com/api_docs/', '自动音频母带处理', 'apiKey', true, 'Yes'),
      PublicApi('Apple Music', 'https://developer.apple.com/documentation/applemusicapi/', 'Apple Music API', 'apiKey', true, 'Unknown'),
      PublicApi('Audius', 'https://audiusproject.com/api', '去中心化音乐流媒体', 'No', true, 'Unknown'),
      PublicApi('Deezer', 'https://developers.deezer.com/api', 'Deezer音乐API', 'OAuth', true, 'Unknown'),
      PublicApi('Discogs', 'https://www.discogs.com/developers/', '音乐数据库和市场', 'apiKey', true, 'Unknown'),
      PublicApi('Genius', 'https://docs.genius.com/', '歌词和音乐知识', 'OAuth', true, 'Unknown'),
      PublicApi('Jamendo', 'https://developer.jamendo.com/v3.0/docs', '免费音乐流媒体和下载', 'OAuth', true, 'Unknown'),
      PublicApi('JioSaavn', 'https://github.com/cyberboysumanjay/JioSaavnAPI', '印度音乐流媒体', 'No', true, 'Unknown'),
      PublicApi('KKBOX', 'https://developer.kkbox.com', '亚洲音乐平台', 'OAuth', true, 'Unknown'),
      PublicApi('LastFm', 'https://www.last.fm/api', '音乐推荐和Scrobbling', 'apiKey', true, 'Unknown'),
      PublicApi('Lyrics.ovh', 'https://lyricsovh.docs.apiary.io/', '简单歌词API', 'No', true, 'Unknown'),
      PublicApi('Mixcloud', 'https://www.mixcloud.com/developers/', '音乐混音和播客', 'OAuth', true, 'Yes'),
      PublicApi('MusicBrainz', 'https://musicbrainz.org/doc/MusicBrainz_API', '开放音乐百科全书', 'No', true, 'Unknown'),
      PublicApi('Napster', 'https://developer.napster.com/api/v2.2', '音乐流媒体', 'apiKey', true, 'Yes'),
      PublicApi('Openwhyd', 'https://openwhyd.github.io/openwhyd/API', '音乐策展平台', 'No', true, 'No'),
      PublicApi('Phishin', 'https://phish.in/api-docs', 'Phish乐队live音乐档案', 'No', true, 'No'),
      PublicApi('Radio Browser', 'https://api.radio-browser.info/', '网络电台目录', 'No', true, 'Yes'),
      PublicApi('Songkick', 'https://www.songkick.com/developer/', '音乐会、音乐节和演出数据', 'apiKey', true, 'Unknown'),
      PublicApi('Songsterr', 'https://www.songsterr.com/a/wa/api/', '吉他谱和和弦', 'No', true, 'Unknown'),
    ],
  ),

  PublicApisCategory(
    'News',
    Icons.newspaper,
    Color(0xFFB71C1C),
    '新闻和媒体API',
    [
      PublicApi('Associated Press', 'https://developer.ap.org/', '搜索美联社新闻内容', 'apiKey', true, 'Unknown'),
      PublicApi('Currents', 'https://currentsapi.services/', '最新新闻发布和数据', 'apiKey', true, 'Yes'),
      PublicApi('Feedster', 'https://api.feedster.app/v1/docs/', '可搜索和分类的新闻API', 'apiKey', true, 'Unknown'),
      PublicApi('GNews', 'https://gnews.io/', 'Google新闻搜索API', 'apiKey', true, 'Yes'),
      PublicApi('Graphs for Coronavirus', 'https://corona.dnsforfamily.com/api.txt', '新冠疫情数据', 'No', true, 'Yes'),
      PublicApi('HackerNews', 'https://github.com/HackerNews/API', 'Hacker News API', 'No', true, 'Unknown'),
      PublicApi('Inshorts News', 'https://github.com/cyberboysumanjay/Inshorts-News-API', '简短新闻API', 'No', true, 'Unknown'),
      PublicApi('Mediastack', 'https://mediastack.com/', '实时全球新闻数据', 'apiKey', true, 'Unknown'),
      PublicApi('New York Times', 'https://developer.nytimes.com/', '纽约时报API', 'apiKey', true, 'Unknown'),
      PublicApi('News', 'https://newsapi.org/', '全球新闻头条', 'apiKey', true, 'Unknown'),
      PublicApi('NewsData', 'https://newsdata.io/docs', '实时新闻数据', 'apiKey', true, 'Unknown'),
      PublicApi('Spaceflight News', 'https://spaceflightnewsapi.net', '航天新闻', 'No', true, 'Yes'),
      PublicApi('The Guardian', 'https://open-platform.theguardian.com/', '卫报新闻API', 'apiKey', true, 'Unknown'),
      PublicApi('The Old Reader', 'https://github.com/theoldreader/api', 'RSS阅读器API', 'apiKey', true, 'Unknown'),
    ],
  ),

  PublicApisCategory(
    'Open Data',
    Icons.public,
    Color(0xFF00695C),
    '开放数据API，包括政府数据、统计数据、公共数据集等',
    [
      PublicApi('18F', 'https://developer.usajobs.gov/', '美国联邦政府数字服务', 'No', false, 'Unknown'),
      PublicApi('Archive.org', 'https://archive.org/services/docs/api/', '互联网档案', 'No', true, 'Unknown'),
      PublicApi('Bureau of Labor Statistics', 'https://www.bls.gov/developers/', '美国劳工统计局', 'apiKey', true, 'Unknown'),
      PublicApi('Census.gov', 'https://www.census.gov/data/developers/data-sets.html', '美国人口普查局', 'No', true, 'Unknown'),
      PublicApi('Data USA', 'https://datausa.io/about/api/', '美国公共数据可视化', 'No', true, 'Unknown'),
      PublicApi('Data.gov', 'https://api.data.gov/', '美国政府开放数据', 'apiKey', true, 'Unknown'),
      PublicApi('Data.parliament.uk', 'https://explore.data.parliament.uk/', '英国议会数据', 'No', true, 'Unknown'),
      PublicApi('Enigma Public', 'https://developers.enigma.com/docs', '公共数据的广阔存档', 'apiKey', true, 'Yes'),
      PublicApi('European Central Bank', 'https://sdw-wsrest.ecb.europa.eu/', '欧洲央行统计数据', 'No', true, 'Unknown'),
      PublicApi('Eurostat', 'https://ec.europa.eu/eurostat/', '欧盟统计局', 'No', true, 'Unknown'),
      PublicApi('GitHub Data', 'https://github.com/fawazahmed0/github-global-data', 'GitHub开源数据', 'No', true, 'Unknown'),
      PublicApi('Google Public Data', 'https://www.google.com/publicdata/directory', 'Google公共数据资源管理器', 'No', true, 'Unknown'),
      PublicApi('OpenCorporates', 'https://api.opencorporates.com/documentation/API-Reference', '全球公司数据', 'apiKey', true, 'Unknown'),
      PublicApi('OpenSanctions', 'https://www.opensanctions.org/docs/api/', '制裁和PEP名单数据', 'No', true, 'Yes'),
      PublicApi('Quandl', 'https://www.quandl.com/', '经济和金融数据', 'apiKey', true, 'Unknown'),
      PublicApi('Recreation Information Database', 'https://ridb.recreation.gov/', '美国娱乐设施数据', 'apiKey', true, 'Unknown'),
      PublicApi('Scoop.it', 'http://www.scoop.it/dev', '内容策展服务', 'apiKey', false, 'Unknown'),
      PublicApi('Teleport', 'https://developers.teleport.org/', '城市生活质量数据', 'No', true, 'Unknown'),
      PublicApi('Universities List', 'https://github.com/Hipo/university-domains-list', '全球大学域名和名称', 'No', true, 'Unknown'),
      PublicApi('WordPress.org', 'https://developer.wordpress.org/rest-api/', 'WordPress REST API', 'No', true, 'Unknown'),
    ],
  ),

  PublicApisCategory(
    'Science & Math',
    Icons.science,
    Color(0xFF1A237E),
    '科学和数学API，包括天文、生物、化学、数学计算等',
    [
      PublicApi('arXiv', 'https://arxiv.org/help/api/user-manual', '物理、数学、CS预印本', 'No', true, 'Unknown'),
      PublicApi('CORE', 'https://core.ac.uk/services#api', '开放获取研究论文', 'apiKey', true, 'Unknown'),
      PublicApi('GBIF', 'https://www.gbif.org/developer/summary', '全球生物多样性信息', 'No', true, 'Yes'),
      PublicApi('iDigBio', 'https://github.com/idigbio/idigbio-search-api/wiki', '数字化生物多样性标本', 'No', true, 'Unknown'),
      PublicApi('ISRO', 'https://isro.vercel.app', '印度空间研究组织数据', 'No', true, 'No'),
      PublicApi('ITIS', 'https://www.itis.gov/ws_description.html', '综合分类信息系统', 'No', true, 'Unknown'),
      PublicApi('Launch Library 2', 'https://thespacedevs.com/llapi', '太空发射数据', 'No', true, 'Yes'),
      PublicApi('Mars Rover Photos', 'https://github.com/chrisccerami/mars-photo-api', 'NASA火星探测器图片', 'No', true, 'No'),
      PublicApi('NASA', 'https://api.nasa.gov', '美国航空航天局数据', 'No', true, 'No'),
      PublicApi('NASA APOD', 'https://github.com/nasa/apod-api', 'NASA每日天文图片', 'No', true, 'Yes'),
      PublicApi('Newton', 'https://newton.vercel.app', '高级数学计算器', 'No', true, 'No'),
      PublicApi('Numbers', 'http://numbersapi.com', '数字有趣的事实', 'No', false, 'No'),
      PublicApi('Open Science Framework', 'https://developer.osf.io', '科学研究平台', 'No', true, 'Unknown'),
      PublicApi('SHARE', 'https://share.osf.io/api/v2/', '研究数据共享', 'No', true, 'No'),
      PublicApi('SpaceX', 'https://github.com/r-spacex/SpaceX-API', 'SpaceX发射和火箭数据', 'No', true, 'No'),
      PublicApi('TLE', 'https://tle.ivanstanojevic.me/#/docs', '卫星两行轨道数据', 'No', true, 'No'),
      PublicApi('USGS Earthquake Catalog', 'https://earthquake.usgs.gov/fdsnws/event/1/', '美国地质调查局地震数据', 'No', true, 'No'),
    ],
  ),

  PublicApisCategory(
    'Social',
    Icons.people,
    Color(0xFF0277BD),
    '社交媒体API，包括社交网络、博客、论坛等',
    [
      PublicApi('Cisco Spark', 'https://developer.ciscospark.com', 'Cisco团队协作', 'OAuth', true, 'Unknown'),
      PublicApi('Discord', 'https://discord.com/developers/docs/intro', '聊天和社区平台', 'OAuth', true, 'Unknown'),
      PublicApi('Disqus', 'https://disqus.com/api/docs/auth/', '评论系统', 'OAuth', true, 'Unknown'),
      PublicApi('Facebook', 'https://developers.facebook.com/', '社交网络', 'OAuth', true, 'Unknown'),
      PublicApi('Foursquare', 'https://developer.foursquare.com/', '位置社交网络', 'apiKey', true, 'Unknown'),
      PublicApi('Fuck Off as a Service', 'https://www.foaas.com', '冒犯性消息生成器', 'No', true, 'Unknown'),
      PublicApi('Full Contact', 'https://docs.fullcontact.com/', '社交图谱和身份解析', 'OAuth', true, 'Unknown'),
      PublicApi('HackerNews', 'https://github.com/HackerNews/API', '科技新闻社交', 'No', true, 'Unknown'),
      PublicApi('Instagram', 'https://developers.facebook.com/docs/instagram-api', '图片社交网络', 'OAuth', true, 'Unknown'),
      PublicApi('Kakao', 'https://developers.kakao.com/', '韩国社交平台', 'OAuth', true, 'Unknown'),
      PublicApi('LINE', 'https://developers.line.biz/', '通讯和社交平台', 'OAuth', true, 'Unknown'),
      PublicApi('LinkedIn', 'https://developer.linkedin.com/', '职业社交网络', 'OAuth', true, 'Unknown'),
      PublicApi('Mastodon', 'https://docs.joinmastodon.org/api/', '去中心化社交网络', 'OAuth', true, 'Unknown'),
      PublicApi('Meetup.com', 'https://www.meetup.com/api/guide', '线下聚会组织', 'apiKey', true, 'Unknown'),
      PublicApi('Pinterest', 'https://developers.pinterest.com/', '图片分享和发现', 'OAuth', true, 'Unknown'),
      PublicApi('Reddit', 'https://www.reddit.com/dev/api', '社交新闻聚合', 'OAuth', true, 'Unknown'),
      PublicApi('Slack', 'https://api.slack.com/', '团队沟通平台', 'OAuth', true, 'Unknown'),
      PublicApi('Telegram', 'https://core.telegram.org/bots/api', '即时通讯平台Bot API', 'apiKey', true, 'Unknown'),
      PublicApi('TikTok', 'https://developers.tiktok.com/doc/login-kit-web', '短视频社交平台', 'OAuth', true, 'Unknown'),
      PublicApi('Tumblr', 'https://www.tumblr.com/docs/en/api/v2', '博客和社交平台', 'OAuth', true, 'Unknown'),
      PublicApi('Twitch', 'https://dev.twitch.tv/docs', '游戏直播平台', 'OAuth', true, 'Unknown'),
      PublicApi('Twitter', 'https://developer.twitter.com/en/docs', '微博社交平台', 'OAuth', true, 'Unknown'),
      PublicApi('VK', 'https://vk.com/dev/sites', '俄罗斯社交网络', 'OAuth', true, 'Unknown'),
    ],
  ),

  PublicApisCategory(
    'Sports & Fitness',
    Icons.fitness_center,
    Color(0xFFBF360C),
    '体育和健身API，包括赛事数据、运动统计、健身追踪等',
    [
      PublicApi('API-FOOTBALL', 'https://www.api-football.com/documentation-v3', '足球数据API', 'apiKey', true, 'Yes'),
      PublicApi('ApiMedic', 'https://apimedic.com/', '健康症状检查', 'apiKey', true, 'Unknown'),
      PublicApi('balldontlie', 'https://www.balldontlie.io', 'NBA数据', 'No', true, 'Yes'),
      PublicApi('Canadian Football League', 'http://api.cfl.ca/', '加拿大橄榄球联赛', 'apiKey', true, 'No'),
      PublicApi('City Bikes', 'https://api.citybik.es/v2/', '全球共享单车网络', 'No', true, 'Unknown'),
      PublicApi('Ergast F1', 'http://ergast.com/mrd/', 'F1赛车历史数据', 'No', true, 'Unknown'),
      PublicApi('Fitbit', 'https://dev.fitbit.com/', '健康和健身数据', 'OAuth', true, 'Unknown'),
      PublicApi('Football', 'https://www.football-data.org/', '足球数据', 'apiKey', true, 'Unknown'),
      PublicApi('Football Standings', 'https://github.com/azharimm/football-standings-api', '足球联赛排名', 'No', true, 'Yes'),
      PublicApi('JCDecaux Bike', 'https://developer.jcdecaux.com/', '共享单车实时数据', 'apiKey', true, 'Unknown'),
      PublicApi('NBA Stats', 'https://any-api.com/nba_com/nba_com/docs/API_Description', 'NBA数据', 'No', true, 'Unknown'),
      PublicApi('NHL Records', 'https://gitlab.com/dword4/nhlapi', 'NHL冰球记录', 'No', true, 'Unknown'),
      PublicApi('Soccer Predictions', 'https://boggio-analytics.com/fp-api/', '足球比赛预测', 'No', true, 'Yes'),
      PublicApi('Sport List & Data', 'https://developers.decathlon.com/products/sports', '体育项目列表和数据', 'No', true, 'Yes'),
      PublicApi('Sport Places', 'https://developers.decathlon.com/products/sport-places', '运动场地搜索', 'No', true, 'Yes'),
      PublicApi('Strava', 'https://strava.github.io/api/', '跑步和骑行追踪', 'OAuth', true, 'Unknown'),
      PublicApi('SuredBits', 'https://suredbits.com/api/', '体育数据和博彩', 'No', false, 'No'),
      PublicApi('TheSportsDB', 'https://www.thesportsdb.com/free_sports_api', '体育赛事和资料', 'apiKey', true, 'Yes'),
      PublicApi('Wger', 'https://wger.de/en/software/api', '健身和营养管理', 'apiKey', true, 'Unknown'),
    ],
  ),

  PublicApisCategory(
    'Weather',
    Icons.cloud_queue,
    Color(0xFF01579B),
    '天气和气象API',
    [
      PublicApi('7Timer!', 'http://www.7timer.info/doc.php', '全球天气预报', 'No', false, 'Unknown'),
      PublicApi('AccuWeather', 'https://developer.accuweather.com/apis', '天气预报和预警', 'apiKey', false, 'Unknown'),
      PublicApi('AEMET OpenData', 'https://opendata.aemet.es/', '西班牙气象局数据', 'apiKey', true, 'Unknown'),
      PublicApi('AirVisual', 'https://www.iqair.com/air-pollution-data-api', '空气质量数据', 'apiKey', true, 'Unknown'),
      PublicApi('AviationWeather', 'https://www.aviationweather.gov/dataserver', '航空天气数据', 'No', true, 'Unknown'),
      PublicApi('HG Weather', 'https://hgbrasil.com/status/weather', '巴西天气数据', 'apiKey', true, 'Yes'),
      PublicApi('Meteorologisk Institutt', 'https://api.met.no/weatherapi/documentation', '挪威气象研究所', 'No', true, 'Unknown'),
      PublicApi('ODWeather', 'http://api.oceandrivers.com/static/docs.html', '天气和 tides', 'No', false, 'Unknown'),
      PublicApi('Open-Meteo', 'https://open-meteo.com/', '免费开源天气API', 'No', true, 'Yes'),
      PublicApi('OpenUV', 'https://www.openuv.io', '全球实时UV指数', 'apiKey', true, 'Unknown'),
      PublicApi('OpenWeatherMap', 'https://openweathermap.org/api', '全球天气数据', 'apiKey', true, 'Unknown'),
      PublicApi('QWeather', 'https://dev.qweather.com/', '和风天气API', 'apiKey', true, 'Unknown'),
      PublicApi('RainViewer', 'https://www.rainviewer.com/api.html', '全球雷达降水数据', 'No', true, 'Unknown'),
      PublicApi('Storm Glass', 'https://stormglass.io/', '全球海洋天气', 'apiKey', true, 'Unknown'),
      PublicApi('Tomorrow.io', 'https://docs.tomorrow.io', '超本地天气预报', 'apiKey', true, 'Unknown'),
      PublicApi('US Weather', 'https://www.weather.gov/documentation/services-web-api', '美国国家气象局', 'No', true, 'Yes'),
      PublicApi('Visual Crossing', 'https://www.visualcrossing.com/weather-api', '全球历史天气数据', 'apiKey', true, 'Yes'),
      PublicApi('WeatherAPI', 'https://www.weatherapi.com/', '免费天气预报和历史数据', 'apiKey', true, 'Yes'),
      PublicApi('WeatherBit', 'https://www.weatherbit.io/api', '天气预报API', 'apiKey', true, 'Unknown'),
      PublicApi('Weatherstack', 'https://weatherstack.com/', '实时和历史天气数据', 'apiKey', true, 'Unknown'),
      PublicApi('Yandex.Weather', 'https://yandex.com/dev/weather/', 'Yandex天气', 'apiKey', true, 'Yes'),
      PublicApi('Yr.no', 'https://developer.yr.no/doc/GettingStarted/', '挪威天气预报', 'No', true, 'Yes'),
    ],
  ),
];
