import os
import re
import json
from bs4 import BeautifulSoup

def extract_signals(html_file, output_dir):
    with open(html_file, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f, 'html.parser')

    signals = soup.find_all('div', class_='signal-card')
    scripts = soup.find_all('script')

    if not signals:
        print("No signals found!")
        return

    os.makedirs(output_dir, exist_ok=True)

    # Extract chart datasets from JavaScript
    chart_js_text = ""
    for script in scripts:
        if script.string and 'new Chart' in script.string:
            chart_js_text += script.string

    for i, signal in enumerate(signals, 1):
        ticker_tag = signal.find('span', class_='ticker')
        ticker = ticker_tag.text.strip() if ticker_tag else f"Signal_{i}"
        ticker_clean = re.sub(r'\W+', '', ticker)

        # Extract other details
        strategy_badge = signal.find('span', class_='strategy-badge').text if signal.find('span', class_='strategy-badge') else "Strategy"
        company_name = signal.find('div', class_='company-name').text if signal.find('div', class_='company-name') else "Company"
        price = signal.find('span', class_='price').text.split()[0] if signal.find('span', class_='price') else "Price"
        change = signal.find('span', class_='change').text if signal.find('span', class_='change') else "Change"

        stats = signal.find_all('div', class_='stat')
        stat_labels = [stat.find('div', class_='stat-label').text for stat in stats]
        stat_values = [stat.find('div', class_='stat-value').text for stat in stats]

        description_div = signal.find('div', class_='strategy-desc')
        description = description_div.text.strip() if description_div else "No Description"
        link_tag = description_div.find('a') if description_div else None
        link_text = link_tag.text.strip('→ ') if link_tag else "More Info"
        link_url = link_tag['href'] if link_tag else "#"

        # Extract JavaScript dataset for each ticker from JS block
        pattern = re.compile(rf"new Chart\(.*?'chart-{ticker.lower()}'.*?data:\s*(\{{.*?\}}),\s*options:", re.DOTALL)
        js_data_match = pattern.search(chart_js_text.lower())
        js_data = js_data_match.group(1) if js_data_match else "{}"

        # Build final HTML content
        filled_html = f"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
          <meta charset="UTF-8">
          <title>{ticker} - {strategy_badge}</title>
          <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
          <style>
            body {{ font-family: 'Segoe UI', sans-serif; background-color: #000; color: #fff; padding: 15px; max-width: 420px; margin: auto; }}
            .signal-card {{ background-color: #1a1a1a; padding: 16px; border-radius: 12px; border: 1px solid #2a2a2a; }}
            .price {{ color: #00ff88; font-weight: bold; }}
            .description {{ color: #aaa; }}
            .link {{ color: #00ff88; text-decoration: none; }}
          </style>
        </head>
        <body>
          <div class="signal-card">
            <div><b>{strategy_badge}</b></div>
            <div style="font-size:20px;">{ticker}</div>
            <div>{company_name}</div>
            <div class="price">{price} ({change})</div>
            <div>
              {stat_labels[0]}: {stat_values[0]}<br>
              {stat_labels[1]}: {stat_values[1]}<br>
              {stat_labels[2]}: {stat_values[2]}
            </div>
            <div class="description">{description}</div>
            <a class="link" href="{link_url}">{link_text} →</a>
          </div>

          <canvas id="chart-{ticker.lower()}" style="margin-top:20px;height:150px;"></canvas>

          <script>
            const ctx = document.getElementById('chart-{ticker.lower()}').getContext('2d');
            const chartData = {js_data};
            new Chart(ctx, {{
              type: 'line',
              data: chartData,
              options: {{
                responsive: true,
                maintainAspectRatio: false,
                plugins: {{
                  legend: {{ display: false }}
                }},
                scales: {{
                  x: {{ display: false }},
                  y: {{ display: false }}
                }}
              }}
            }});
          </script>
        </body>
        </html>
        """

        output_path = os.path.join(output_dir, f"{ticker_clean}_{i}.html")
        with open(output_path, 'w', encoding='utf-8') as file_out:
            file_out.write(filled_html)

        print(f"Generated: {output_path}")

if __name__ == "__main__":
    extract_signals('v13.html', 'signals_with_charts')
