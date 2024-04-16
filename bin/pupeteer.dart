import 'dart:io';

import 'package:puppeteer/puppeteer.dart';

void main() async {
  //Define quais linguagens quer buscar vagas, a busca só considerará vagas remotas e que permitam inscrição do Brasil.
  final queries = [
    'Flutter',
    'React Native',
    'Swift',
    'Kotlin',
    'Python',
  ];

  Map<String, int> quantities = {};
  for (final query in queries) {
    final quantity = await likidinJobsByQuery(query);
    quantities[query] = quantity;
  }
  quantities.forEach(
    (key, value) => print('Quantidade de vagas para $key: $value'),
  );
}

Future<int> likidinJobsByQuery(String query) async {
  final url =
      'https://www.linkedin.com/jobs/search/?f_WT=2&keywords=$query&origin=JOB_SEARCH_PAGE_JOB_FILTER&refresh=true&sortBy=DD&location=Brasil';
  final browser = await puppeteer.launch(
    noSandboxFlag: true,
    args: ['--disable-setuid-sandbox'],
    executablePath: BrowserPath.chrome,
  );
  final page = await browser.newPage();

  navigate() async {
    try {
      await page.goto(url, wait: Until.networkAlmostIdle);
      final screenshot = await page.screenshot(fullPage: true);
      await File('D:/Projetos/pupeteer/$query.png').writeAsBytes(screenshot);
    } catch (e) {
      return;
    }
  }

  Future<int?> getQuantity() async {
    try {
      await navigate();
      final handle1 = await page.$('.results-context-header__job-count');
      final quantity = await handle1.evaluate('node=>node.innerText') as String;
      return int.parse(quantity.replaceAll('+', '').replaceAll(',', ''));
    } catch (e) {
      await navigate();
      return null;
    }
  }

  int? quantity = await getQuantity();
  int n = 0;
  final maxTries = 10;
  while (quantity == null) {
    quantity = await getQuantity();
    n++;
    print('Tentativa de $query: $n');
    if (n > maxTries) {
      throw 'Não foi possível calcular a quantidade para $query';
    }
  }

  await browser.close();
  return quantity;
}
