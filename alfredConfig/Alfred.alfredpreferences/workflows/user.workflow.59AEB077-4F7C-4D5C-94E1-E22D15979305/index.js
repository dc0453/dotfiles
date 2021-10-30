const path = require('path');
const https = require('https');
const fs = require('fs');

const keyword = process.argv[2]; // 搜索的正则表达式关键字
const url = 'https://raw.githubusercontent.com/any86/any-rule/master/packages/www/src/RULES.js';

function fetchData() {
    return new Promise((resolve, reject) => {
        https.get(url, async res => {
            // 处理返回数据
            res.setEncoding('utf8');
            let rawData = '';
            res.on('data', (chunk) => { rawData += chunk.trim(); });
            res.on('end', () => {
                try {
                    // 获取正则表达式数据
                    const arrStr = rawData.split(' = ')[1].trim();
                    
                    fs.writeFile('./RULES.txt', arrStr, err => {
                        if (err) {
                            reject(err);
                        } else {
                            console.log(JSON.stringify({
                                items: [{
                                    title: '本地数据已经更新完成，可重新输入关键字搜索~',
                                    subtitle: '已完成',
                                    icon: {
                                        path: path.join(__dirname, './icon.png'),
                                    },
                                }]
                            }))
                            resolve();
                        }
                    })
                } catch (e) {
                    reject(e.message);
                }
            });
        })
    })
}

async function readLocalFile() {
    return new Promise((resolve, reject) => {
        if (fs.existsSync('./RULES.txt')) {
            fs.readFile('./RULES.txt', 'utf8', (err, data) => {
                if (err) reject(err)
                const list = eval(data);
                resolve(list);
            })
        } else {
            resolve(null);
        }
    })
}

async function main() {
    // 指令是 zzupdate 表示手动更新数据
    if (keyword == 'zzupdate') {
        console.log(JSON.stringify({
            items: [{
                title: '1111',
                subtitle: '222',
                icon: {
                    path: path.join(__dirname, './icon.png'),
                },
            }]
        }))
        await fetchData();
    } else {
        const list = await readLocalFile();

        if (list == null) {
            console.log(JSON.stringify({
                items: [{
                    title: '本地数据不存在，请输入 zzupdate 命令进行更新~',
                    subtitle: '输入完毕重新查询',
                    icon: {
                        path: path.join(__dirname, './icon.png'),
                    },
                    arg: 'zzupdate'
                }]
            }))
            return;
        } 

        const result = list && list.map(ele => {
            return {
                title: ele.title,
                subtitle: '' + ele.rule,
                icon: {
                    path: path.join(__dirname, './icon.png'),
                },
                arg: '' + ele.rule,
            }
        }).filter(ele => {
            return ele.title.indexOf(keyword) > -1;
        }) || []

        if (result && result.length === 0) {
            console.log(JSON.stringify({
                items: [{
                    title: '未找到符合要求的结果~',
                    subtitle: '请重新选择关键字，或者更新本地数据源再试试~',
                    icon: {
                        path: path.join(__dirname, './icon.png'),
                    },
                }]
            }))
        } else {
            console.log(JSON.stringify({
                items: result
            }))
        }
    }
}

main();