import yaml
from flask import Flask, request, jsonify
from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedMap

app = Flask(__name__)
CONFIG_FILE = "clash.yaml"

def load_config():
    """ 加载 YAML 配置文件 """
    yaml_handler = YAML(typ='rt')  # 使用 RoundTrip 模式
    yaml_handler.preserve_quotes = True
    with open(CONFIG_FILE, "r", encoding="utf-8") as f:
        return yaml_handler.load(f)

def save_config(data):
    """ 保存 YAML 配置文件 """
    yaml_handler = YAML(typ='rt')  # 使用 RoundTrip 模式
    yaml_handler.indent(mapping=2, sequence=4, offset=2)
    yaml_handler.width = 4096
    yaml_handler.block_seq_indent = 1
    
    # 处理代理数据（保持现有代码不变）
    if "proxies" in data:
        for proxy in data["proxies"]:
            if "port" in proxy and isinstance(proxy["port"], str):
                try:
                    proxy["port"] = int(proxy["port"])
                except ValueError:
                    pass
    
    with open(CONFIG_FILE, "w", encoding="utf-8") as f:
        yaml_handler.dump(data, f)

@app.route('/config', methods=['POST'])
def update_config():
    data = request.json
    if "name" not in data or "server" not in data or "port" not in data or "password" not in data:
        return jsonify({"error": "Invalid request"}), 400

    # 读取现有 Clash 配置
    config = load_config()

    # 创建新的代理条目
    new_proxy = CommentedMap()
    new_proxy["name"] = data["name"]
    new_proxy["type"] = "hysteria2"
    
    # 处理 IPv6 地址的格式
    server = data["server"].strip()
    if ':' in server and not (server.startswith('[') and server.endswith(']')):
        server = f'[{server}]'
    new_proxy["server"] = server
    
    # 确保端口是整数
    try:
        new_proxy["port"] = int(str(data["port"]).strip())
    except ValueError:
        new_proxy["port"] = data["port"]
    
    new_proxy["password"] = data["password"]
    new_proxy["sni"] = "bing.com"
    new_proxy["skip-cert-verify"] = True

    # 添加到 proxies 列表
    if "proxies" in config:
        config["proxies"].append(new_proxy)
    else:
        config["proxies"] = [new_proxy]

    # 添加代理到 proxy-groups 的 QingFeng International Airport 组
    for group in config.get("proxy-groups", []):
        if group["name"] == "QingFeng International Airport":
            group["proxies"].append(data["name"])
            group["proxies"].append('\n')  # 添加空行
            break

    # 保存修改后的配置
    save_config(config)

    return jsonify({"message": "Config updated successfully!"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=54321)
