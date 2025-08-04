import os
from bs4 import BeautifulSoup

def extract_signals(html_file, output_dir):
    with open(html_file, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f, 'html.parser')

    signals = soup.find_all('div', class_='signal-card')
    if not signals:
        print("No signals found!")
        return

    os.makedirs(output_dir, exist_ok=True)

    for i, signal in enumerate(signals, 1):
        # Extract details
        ticker = signal.find('span', class_='ticker').text if signal.find('span', class_='ticker') else "Signal"
        strategy_badge = signal.find('span', class_='strategy-badge').text if signal.find('span', class_='strategy-badge') else "Strategy"
        company_name = signal.find('div', class_='company-name').text if signal.find('div', class_='company-name') else "Company"
        price = signal.find('span', class_='price').text if signal.find('span', class_='price') else "Price"
        change = signal.find('span', class_='change').text if signal.find('span', class_='change') else "Change"

        stats = signal.find_all('div', class_='stat')
        stat_labels = [stat.find('div', class_='stat-label').text for stat in stats]
        stat_values = [stat.find('div', class_='stat-value').text for stat in stats]

        description_div = signal.find('div', class_='strategy-desc')
        description = description_div.text.strip() if description_div else "No Description"
        link_tag = description_div.find('a') if description_div else None
        link_text = link_tag.text.strip('→ ') if link_tag else "More Info"
        link_url = link_tag['href'] if link_tag else "#"

        # Load template and replace placeholders
        html_template = open('template.html', 'r', encoding='utf-8').read()
        filled_html = html_template.format(
            TICKER=ticker,
            STRATEGY=strategy_badge,
            COMPANY_NAME=company_name,
            PRICE=price.split()[0],
            CHANGE=change,
            STAT1_LABEL=stat_labels[0] if len(stat_labels) > 0 else "Stat1",
            STAT1_VALUE=stat_values[0] if len(stat_values) > 0 else "-",
            STAT2_LABEL=stat_labels[1] if len(stat_labels) > 1 else "Stat2",
            STAT2_VALUE=stat_values[1] if len(stat_values) > 1 else "-",
            STAT3_LABEL=stat_labels[2] if len(stat_labels) > 2 else "Stat3",
            STAT3_VALUE=stat_values[2] if len(stat_values) > 2 else "-",
            DESCRIPTION=description,
            LINK_URL=link_url,
            LINK_TEXT=link_text
        )

        output_path = os.path.join(output_dir, f"{ticker}_{i}.html")
        with open(output_path, 'w', encoding='utf-8') as file_out:
            file_out.write(filled_html)
        print(f"Generated: {output_path}")

if __name__ == "__main__":
    extract_signals('v13.html', 'signals_output')
