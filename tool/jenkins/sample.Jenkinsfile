/* groovylint-disable-next-line CompileStatic */
pipeline {
    agent any
    environment {
        PATH = "/usr/local/bin:$PATH"
    }
    options {
        timeout(time: 1, unit: 'HOURS') // 每个 Stage 内超时设为 1 小时
        retry(3) // 由于设置了超时终止，可以使用 retry 自动重试，可放到 stage 的 options 里面
        disableConcurrentBuilds() // 不允许并发构建
        buildDiscarder(
            logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '10')
        )
    // checkoutToSubdirectory('foo') // checkout 到指定子目录
    // 需要额外安装的插件
    // ansiColor('xterm') // 插件 AnsiColor
    // timestamps() // 插件 Timestamper
    }
    parameters {
        choice(
            name: 'door_choice',
            choices: ['One', 'Two', 'Three'],
            description: 'What door do you choose?'
        )
        booleanParam(
            name: 'can_dance',
            defaultValue: true,
            description: 'Checkbox parameters'
        )
        string(
            name: 'input_text',
            defaultValue: 'aaa',
            description: 'ccc'
        )
    }
    stages {
        stage('检测输入参数') {
            steps {
                script {
                    println params.door_choice
                    println params.can_dance
                    println params.aaa
                }
            }
        }
        stage('检查环境') {
            steps {
                echo '磁盘剩余空间 20G 20%'
                echo '剩余内存 32G 50%'
            }
        }
        stage('编译') {
            steps {
                echo '编译完成'
            }
        }
        stage('上传') {
            steps {
                echo '上传完成'
            }
        }
        stage('停止服务') {
            steps {
                echo 'xxx停止完成'
            }
        }
        stage('启动服务') {
            steps {
                echo 'xxx运行xxx服务成功'
            }
        }
        stage('健康检测') {
            steps {
                echo '访问端口，HTTP 200 OK，服务正常'
            }
        }
        stage('失败回滚') {
            steps {
                echo '回滚版本xxx已完成'
            }
        }
    }
    post {
        always {
            echo 'pipeline finished'
            echo '通知结果发送至...'
        // cleanWs() // 清理工作空间 需要安装插件： Workspace Cleanup
        }
    }
}
