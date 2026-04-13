# 设置默认IP地址
sed -i 's/192.168.1.1/10.0.0.3/g' package/base-files/files/bin/config_generate

# 清除登陆密码
sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' package/lean/default-settings/files/zzz-default-settings


# 调整 Docker 到 服务 菜单
sed -i 's/"admin"/"admin", "services"/g' feeds/luci/applications/luci-app-dockerman/luasrc/controller/*.lua
sed -i 's/"admin"/"admin", "services"/g; s/admin\//admin\/services\//g' feeds/luci/applications/luci-app-dockerman/luasrc/model/cbi/dockerman/*.lua
sed -i 's/admin\//admin\/services\//g' feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/*.htm
sed -i 's|admin\\|admin\\/services\\|g' feeds/luci/applications/luci-app-dockerman/luasrc/view/dockerman/container.htm

./scripts/feeds update -a
./scripts/feeds install -a

# ==============================
# OpenClash 组件
# ==============================

echo "CONFIG_PACKAGE_luci-app-openclash=y" >> .config
echo "CONFIG_PACKAGE_luci-i18n-openclash-zh-cn=y" >> .config

# ==============================
# 依赖（关键）
# ==============================

echo "CONFIG_PACKAGE_kmod-tun=y" >> .config
echo "CONFIG_PACKAGE_dnsmasq-full=y" >> .config
echo "CONFIG_PACKAGE_iptables-nft=y" >> .config
echo "CONFIG_PACKAGE_ipset=y" >> .config

# ==============================
# Clash Meta Core（x86_64稳定版）
# ==============================

CORE_DIR="files/etc/openclash/core"
mkdir -p $CORE_DIR

URL1="https://ghproxy.com/https://github.com/MetaCubeX/Clash.Meta/releases/latest/download/clash.meta-linux-amd64.gz"
URL2="https://mirror.ghproxy.com/https://github.com/MetaCubeX/Clash.Meta/releases/latest/download/clash.meta-linux-amd64.gz"

wget -O clash_meta.gz $URL1 || wget -O clash_meta.gz $URL2

if [ ! -s clash_meta.gz ]; then
    echo "❌ Core 下载失败"
    exit 1
fi

gunzip -f clash_meta.gz
mv clash.meta-linux-amd64 $CORE_DIR/clash_meta
chmod +x $CORE_DIR/clash_meta

# ==============================
# 默认启动 OpenClash
# ==============================

mkdir -p files/etc/uci-defaults

cat > files/etc/uci-defaults/99-openclash <<'EOF'
uci set openclash.config.enable=1
uci commit openclash
EOF

chmod +x files/etc/uci-defaults/99-openclash
