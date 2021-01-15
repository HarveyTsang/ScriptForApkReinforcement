# ScriptForApkReinforcement
用于加固并重签名apk的脚本(使用腾讯乐固加固)

### 使用方式
1. 将待加固 apk 文件放在 input 文件夹中
2. 将 apksigner.jar 路径填入 `APKSIGNER_JAR_PATH` 变量。apksigner.jar 可在 Android SDK 的 build tools 文件夹下找到。Android SDK 的路径可通过 AndroidStudio -> Preferences -> System Settings -> Android SDK 查看。
3. 将乐固 secret id、secret key 填入 `LEGU_SECRET_ID` 和`LEGU_SECRET_KEY`变量。 secret id、secret key 可在 [腾讯乐固](https://cloud.tencent.com) 申请获得。
4. 往 `KEYSTORE_PATH`、`ALIAS`、`KS_PASSWORD`、`KEY_PASSWORD` 中填入重签名所需的 .jks 文件路径、别名、密钥库密码、密钥密码
5. 根据需求设置采用的签名方案： `V1_SIGN_ENABLE` `V2_SIGN_ENABLE` `V3_SIGN_ENABLE` `V4_SIGN_ENABLE`。
6. 命令行执行:
```
cd src
sh reinforceAPK.sh
```
7. output 文件夹中将得到加固重签后的apk文件。