<!-- b y 7 5 2 7  1 8 9 2 0 -->
<template>
  
  <div class="main">
   <div class="box">
    <div class="left">
      <div class="center">
         <br/>
        欢迎登录
      </div>
    </div>
    <div class="right">
        <div class="tittle">云ERP系统</div>
        <a-form :form="form" class="user-layout-login" ref="formLogin" id="formLogin">
      <a-form-item>
        <a-input
          size="large"
          v-decorator="['loginName',{initialValue:'', rules: validatorRules.loginName.rules}]"
          type="text"
          @focus="initWeixin"
          placeholder="请输入用户名"
          class="inp">
          <a-icon slot="prefix" type="user" :style="{ color: 'rgba(0,0,0,.25)' }"/>
        </a-input>
      </a-form-item>

      <a-form-item>
        <a-input
          v-decorator="['password',{initialValue:'', rules: validatorRules.password.rules}]"
          size="large"
          type="password"
          autocomplete="false"
          placeholder="密码"
          class="inp">
          <a-icon slot="prefix" type="lock" :style="{ color: 'rgba(0,0,0,.25)' }"/>
        </a-input>
      </a-form-item>

      <a-form-item>
        <router-link v-if="registerFlag==='1'" :to="{ name: 'register'}" class="forge-password" style="float: right;margin-right: 100px;font-size:15px;" >
          用户注册
        </router-link>
        <p @click="toAdmin" class="forge-password" style="float: left;font-size:15px;">忘记密码？</p>
         <!-- <router-link  v-if="registerFlag==='1'"  @click="toAdmin" class="forge-password" style="float: left;font-size:20px;" >
          重置密码
        </router-link> -->
      </a-form-item>

      <a-form-item style="margin-top:24px">
        <a-button
         
          size="large"
          type="primary"
          htmlType="submit"
          class="login-button"
          :loading="loginBtn"
          @click.stop.prevent="handleSubmit"
          :disabled="loginBtn"
           >
           确定
         
        </a-button>
      </a-form-item>

      <div class="login-copyright">
        <a-row>
          <a-col>
          
          </a-col>
        </a-row>
      </div>

      
    </a-form> 
    </div>
   </div>





    <!-- <p class="tittle">为新科技</p>
    <a-form :form="form" class="user-layout-login" ref="formLogin" id="formLogin">
      <a-form-item>
        <a-input
          size="large"
          v-decorator="['loginName',{initialValue:'', rules: validatorRules.loginName.rules}]"
          type="text"
          @focus="initWeixin"
          placeholder="请输入用户名">
          <a-icon slot="prefix" type="user" :style="{ color: 'rgba(0,0,0,.25)' }"/>
        </a-input>
      </a-form-item>

      <a-form-item>
        <a-input
          v-decorator="['password',{initialValue:'', rules: validatorRules.password.rules}]"
          size="large"
          type="password"
          autocomplete="false"
          placeholder="密码">
          <a-icon slot="prefix" type="lock" :style="{ color: 'rgba(0,0,0,.25)' }"/>
        </a-input>
      </a-form-item>

      <a-form-item>
        <router-link v-if="registerFlag==='1'" :to="{ name: 'register'}" class="forge-password" style="float: right;margin-right: 10px;" >
          用户注册
        </router-link>
      </a-form-item>

      <a-form-item style="margin-top:24px">
        <a-button
          size="large"
          type="primary"
          htmlType="submit"
          class="login-button"
          :loading="loginBtn"
          @click.stop.prevent="handleSubmit"
          :disabled="loginBtn">确定
        </a-button>
      </a-form-item>

      <div class="login-copyright">
        <a-row>
          <a-col>
          
          </a-col>
        </a-row>
      </div>

      <div v-if="showWeixinFlag" style="text-align: center; padding-top: 10px;">
        <img src="/static/weixin.jpg" style="width:258px" />
      </div>
    </a-form> -->

</div>

</template>
<!-- BY cao_yu_li -->
<script>
  import md5 from "md5"
  import api from '@/api'
  import TwoStepCaptcha from '@/components/tools/TwoStepCaptcha'
  import { mapActions } from "vuex"
  import { timeFix } from "@/utils/util"
  import Vue from 'vue'
  import {getPlatformConfigByKey } from '@/api/api'
  import { ACCESS_TOKEN ,ENCRYPTED_STRING} from "@/store/mutation-types"
  import { putAction,postAction,getAction } from '@/api/manage'
  import { encryption , getEncryptedString } from '@/utils/encryption/aesEncrypt'
  import store from '@/store/'
  import { USER_INFO } from "@/store/mutation-types"
  import pick from 'lodash.pick'

  export default {
    components: {
      TwoStepCaptcha
    },
    data () {
      return {
        customActiveKey: "tab1",
        systemTitle: "为新",
        systemUrl: 1,
        loginBtn: false,
        // login type: 0 email, 1 username, 2 telephone
        loginType: 0,
        requiredTwoStepCaptcha: false,
        stepCaptchaVisible: false,
        form: this.$form.createForm(this),
        encryptedString:{
          key:"",
          iv:"",
        },
        state: {
          time: 60,
          smsSendBtn: false,
        },
        validatorRules:{
          loginName:{rules: [{ required: true, message: '请输入用户名!'},{validator: this.handleLoginName}]},
          password:{rules: [{ required: true, message: '请输入密码!',validator: 'click'}]}
        },
        verifiedCode:"",
        inputCodeContent:"", //20200510 cfm: 为方便测试，不输入验证码可 ""-->"xxxx"
        inputCodeNull:true,
        departList:[],
        departVisible:false,
        departSelected:"",
        currentUsername:"",
        validate_status:"",
        currdatetime:'',
        randCodeImage:'',
        registerFlag:'',
        requestCodeSuccess:false,
        showWeixinFlag:false,
      }
    },
    created () {
      this.currdatetime = new Date().getTime();
      Vue.ls.remove(ACCESS_TOKEN)
      this.getRouterData()
      this.getRegisterFlag()
    },
    methods: {
      ...mapActions([ "Login", "Logout" ]),
      // handler
      handleLoginName (rule, value, callback) {
        const regex = /^([a-zA-Z0-9_-])+@([a-zA-Z0-9_-])+((\.[a-zA-Z0-9_-]{2,3}){1,2})$/;
        if (regex.test(value)) {
          this.loginType = 0
        } else {
          this.loginType = 1
        }
        callback()
      },

      //联系管理员重置密码
      toAdmin() {
        alert("请联系管理员重置密码");
      },
      handleSubmit () {
        let that = this
        let loginParams = {};
        that.loginBtn = true;
        // 使用账户密码登陆
        if (that.customActiveKey === 'tab1') {
          that.form.validateFields([ 'loginName', 'password', 'rememberMe' ], { force: true }, (err, values) => {
            if (!err) {
              loginParams.loginName = values.loginName
              loginParams.password = md5(values.password)
              //loginParams.remember_me = values.rememberMe
              //console.log("登录参数",loginParams)
              that.Login(loginParams).then((res) => {
                this.departConfirm(res, loginParams.loginName)
              }).catch((err) => {
                that.requestFailed(err);
              });
            }else {
              that.loginBtn = false;
            }
          })
        }
      },
      loginSuccess (res) {
        this.$router.push({ path: "/dashboard/analysis" })
        this.$notification.success({
          message: '欢迎',
          description: `${timeFix()}，欢迎回来`,
        });
        if(res.data && res.data.user) {
          if(res.data.user.loginName === 'admin'){
            let desc = 'admin只是平台运维用户，真正的管理员是租户(测试账号为jsh），admin不能编辑任何业务数据，只能配置平台菜单和创建租户'
            this.$message.info(desc,30)
          } else {
            getAction("/user/infoWithTenant",{}).then(res=>{
              if(res && res.code === 200) {
                let currentTime = new Date(); //新建一个日期对象，默认现在的时间
                let expireTime = new Date(res.data.expireTime); //设置过去的一个时间点，"yyyy-MM-dd HH:mm:ss"格式化日期
                let type = res.data.type  //租户类型，0免费租户，1付费租户
                let difftime = expireTime - currentTime; //计算时间差
                let tipInfo = '您好，服务即将到期，请及时续费！'
                //0免费租户-如果距离到期还剩5天就进行提示续费
                if(type === '0' && difftime<86400000*5) {
                  this.$message.warning(tipInfo,8)
                }
                //1付费租户-如果距离到期还剩15天就进行提示续费
                if(type === '1' && difftime<86400000*15) {
                  this.$message.warning(tipInfo,8)
                }
              }
            })
          }
        }
        this.initMPropertyShort();
      },
      cmsFailed(err){
        this.$notification[ 'error' ]({
          message: "登录失败",
          description:err,
          duration: 4,
        });
      },
      requestFailed (err) {
        this.$notification[ 'error' ]({
          message: '登录失败',
          description: ((err.response || {}).data || {}).message || err.message || "请求出现错误，请稍后再试",
          duration: 4,
        });
        this.loginBtn = false;
      },
      generateCode(value){
        this.verifiedCode = value.toLowerCase()
      },
      departConfirm(res, loginName){
        if(res.code==200){
          let err = {};
          if(res.data.msgTip == 'user can login'){
            Vue.ls.set('winBtnStrList', res.data.userBtn, 7 * 24 * 60 * 60 * 1000);
            Vue.ls.set('roleType', res.data.roleType, 7 * 24 * 60 * 60 * 1000);
            this.loginSuccess(res)
          } else if(res.data.msgTip == 'user is not exist'){
            err.message = '用户不存在';
            this.requestFailed(err)
            this.Logout();
          } else if(res.data.msgTip == 'user password error'){
            err.message = '用户密码不正确';
            this.requestFailed(err)
            this.Logout();
          } else if(res.data.msgTip == 'user is black'){
            err.message = '用户被禁用';
            this.requestFailed(err)
            this.Logout();
          } else if(res.data.msgTip == 'tenant is black'){
            if(loginName === 'jsh') {
              err.message = 'jsh用户已停用，请注册租户进行体验！';
            } else {
              err.message = '用户所属的租户被禁用';
            }
            this.requestFailed(err)
            this.Logout();
          } else if(res.data.msgTip == 'tenant is expire'){
            err.message = '试用期已结束，请联系客服续费';
            this.requestFailed(err)
            this.Logout();
          } else if(res.data.msgTip == 'access service error'){
            err.message = '查询服务异常';
            this.requestFailed(err)
            this.Logout();
          }
        }else{
          this.requestFailed(res)
          this.Logout();
        }
      },
      getRouterData(){
        this.$nextTick(() => {
          if (this.$route.params.username) {
            this.form.setFieldsValue({
              'username': this.$route.params.username
            });
          }
        })
      },
      getRegisterFlag(){
        getPlatformConfigByKey( {"platformKey": "register_flag"}).then((res)=>{
          if(res && res.code == 200) {
            this.registerFlag = res.data.platformValue
          }
        })
      },
      //获取密码加密规则
      getEncrypte(){
        var encryptedString = Vue.ls.get(ENCRYPTED_STRING);
        if(encryptedString == null){
          getEncryptedString().then((data) => {
            this.encryptedString = data
          });
        }else{
          this.encryptedString = encryptedString;
        }
      },
      //加载商品属性
      initMPropertyShort(){
        let mPropertyListShort = '';
        let params = {};
        params.currentPage = 1;
        params.pageSize = 100;
        getAction('/materialProperty/list', params).then((res) => {
          if(res && res.code === 200){
            if(res.data) {
              let thisRows = res.data.rows; //属性列表
              Vue.ls.set('materialPropertyList', thisRows, 7 * 24 * 60 * 60 * 1000);
            }
          }
        })
      },
      initWeixin() {
        if(this.showWeixinSpan()) {
          let that = this
          setTimeout(function() {
            that.showWeixin()
          },1000)
        }
      },
      showWeixinSpan() {
        let host = window.location.host
        if(host === 'cloud.huaxiaerp.vip') {
          return true
        } else {
          return false
        }
      },
      showWeixin() {
        this.showWeixinFlag = true
      },
      changeWeixinStatus() {
        if(this.showWeixinFlag) {
          this.showWeixinFlag = false
        } else {
          this.showWeixinFlag = true
        }
      },
    }
  }
</script>

<style lang="less" scoped>
 
  .user-layout-login {
    padding-left: 100px;
    label {
      font-size: 14px;
      
    }

    .getCaptcha {
      display: block;
      width: 100%;
      height: 40px;
    }

    .forge-password {
      color: #1890ff;
      font-size: 14px;
      font-weight: bolder;
    }

    .forge-password:hover {
      cursor: pointer;
      color: blue;
      text-decoration:underline
    }

    

    button.login-button {
      padding: 0 15px;
      font-size: 16px;
      height: 45px;
      width: 79%;
    }

    .user-login-other {
      text-align: left;
      margin-top: 24px;
      line-height: 22px;

      .item-icon {
        font-size: 24px;
        color: rgba(0,0,0,.2);
        margin-left: 16px;
        vertical-align: middle;
        cursor: pointer;
        transition: color .3s;

        &:hover {
          color: #1890ff;
        }
      }

      .register {
        float: right;
      }
    }

    .weixin {
      padding-left:10px;
      color: red;
      cursor:pointer
    }
   
  }

</style>
<style>
  .valid-error .ant-select-selection__placeholder{
    color: #f5222d;
  }
  .login-copyright {
    text-align: center;
    margin-top: 20px
  }
  /* .login-copyright, .login-copyright a {
    color: #666
  } */
  .main {
    display: flex;
    align-items: center; 
    justify-content: center; 

  }
  .main .box {
    width: 850px;
    height: 400px;
    display: flex;
    border-radius: 15px;
  }

  .main .box .left {
    background: url('~@/assets/bg1.jpg') no-repeat;
    background-size:100% 100%;
    width: 300px;
    border-radius: 15px;
  }
  .main .box .left .center {
      text-align: center;
      padding-top: 100px;
      font-size: 35px;
      color: white;
    }

  .main .box .right {
    background-color: white;
    flex: 1;
    border-radius: 15px;
    margin: 0 auto;
  }
  .right .tittle {
    padding-top: 30px;
    padding-bottom: 30px;
    font-size: 30px;

    text-align: center;
  }
  .inp {
    text-align: center;
    width: 350px;
    height: 45px;
    color: aliceblue;
  }
   
</style>