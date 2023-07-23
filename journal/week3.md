# Week 3 — Decentralized Authentication

After implementing week 2 and studying about opentelemetry, I had to give a brief study about what is decentralised authentications and how it works. I used ChatGPT and other docs to gain some insights.
I blindly followed all the videos in the official playlist and was able to implement the required homeworks, although I faced some of the problems but I was working hard to get them done. I took the help of some really helpful bootcampers and my feek was a succeess. Journaling what I have done:- 

## Install AWS Amplify
* `--save` to save the *aws-amplify* in `package.json`
* The package was installed in the `frontend-react-js` path. `package.json` and `package-lock.json` will be changed accordingly with the Amplify package.
```sh
npm i aws-amplify --save
```
-------------
## Setup Cognito User Pool
* From AWS management console, I created a user pool name "cruddur-user-pool".
#### Sign-in experience
* I choose Sign-in option to ***Email only*** (our configuration so far!). To lessen the spend that was the best solution.
#### Security requirements
* I opted with the cognito default password complexity policy and set with ***NO MFA*** required.
* To reduce costs I picked the ***Email only*** method for user confiramtion and recovery.
#### Sign-up experience implementation
* Enable ***self registration***, so users can create accounts.
* Required attribute (email) .. optional attributes (*name, preferred_username*).
#### Message delivery
* Configured message delivery by email instead of SES
#### App Integration
* I set user pool name `cruddur-user-pool`, App client name `cruddur`.
* App type is ***Public client***.
Then we can retrieve the user pool id and app client id.
![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/e841993e-539b-40c0-a847-6763b2201d47)
--------

## Configure Amplify
I added this code in `app.js` of frontend-react-js directory.
```js
import { Amplify } from 'aws-amplify';

Amplify.configure({
  "AWS_PROJECT_REGION": process.env.REACT_AWS_PROJECT_REGION,
  "aws_cognito_identity_pool_id": process.env.REACT_APP_AWS_COGNITO_IDENTITY_POOL_ID,
  "aws_cognito_region": process.env.REACT_APP_AWS_COGNITO_REGION,
  "aws_user_pools_id": process.env.REACT_APP_AWS_USER_POOLS_ID,
  "aws_user_pools_web_client_id": process.env.REACT_APP_CLIENT_ID,
  "oauth": {},
  Auth: {
    // We are not using an Identity Pool
    // identityPoolId: process.env.REACT_APP_IDENTITY_POOL_ID, // REQUIRED - Amazon Cognito Identity Pool ID
    region: process.env.REACT_AWS_PROJECT_REGION,           // REQUIRED - Amazon Cognito Region
    userPoolId: process.env.REACT_APP_AWS_USER_POOLS_ID,         // OPTIONAL - Amazon Cognito User Pool ID
    userPoolWebClientId: process.env.REACT_APP_AWS_USER_POOLS_WEB_CLIENT_ID,   // OPTIONAL - Amazon Cognito Web Client ID (26-char alphanumeric string)
  }
});
```

In the above code set these below env vars in `docker-compose.yml`.
```js
REACT_APP_AWS_PROJECT_REGION= ""
REACT_APP_AWS_COGNITO_IDENTITY_POOL_ID= ""
REACT_APP_AWS_COGNITO_REGION= ""
REACT_APP_AWS_USER_POOLS_ID= ""
REACT_APP_CLIENT_ID= ""
```
* Then to check the **Authentication Process** I added this code in my `HomeFeedPage.js`
```js
import { Auth } from 'aws-amplify';

// set a state
const [user, setUser] = React.useState(null);

// check if we are authenicated
const checkAuth = async () => {
  Auth.currentAuthenticatedUser({
    // Optional, By default is false. 
    // If set to true, this call will send a 
    // request to Cognito to get the latest user data
    bypassCache: false 
  })
  .then((user) => {
    console.log('user',user);
    return Auth.currentAuthenticatedUser()
  }).then((cognito_user) => {
      setUser({
        display_name: cognito_user.attributes.name,
        handle: cognito_user.attributes.preferred_username
      })
  })
  .catch((err) => console.log(err));
};

// check when the page loads if we are authenicated
React.useEffect(()=>{
  loadData();
  checkAuth();
}, [])
```
* To render two React components: `DesktopNavigation` and `DesktopSidebar`, passing some properties to each of them.
```js
<DesktopNavigation user={user} active={'home'} setPopped={setPopped} />
<DesktopSidebar user={user} />
```
* Then I added this code in `DesktopNavigation.js` which helps you to check whether you are logged in or not by passing the`user` to `ProfileInfo`.
```js
import './DesktopNavigation.css';
import {ReactComponent as Logo} from './svg/logo.svg';
import DesktopNavigationLink from '../components/DesktopNavigationLink';
import CrudButton from '../components/CrudButton';
import ProfileInfo from '../components/ProfileInfo';

export default function DesktopNavigation(props) {

  let button;
  let profile;
  let notificationsLink;
  let messagesLink;
  let profileLink;
  if (props.user) {
    button = <CrudButton setPopped={props.setPopped} />;
    profile = <ProfileInfo user={props.user} />;
    notificationsLink = <DesktopNavigationLink 
      url="/notifications" 
      name="Notifications" 
      handle="notifications" 
      active={props.active} />;
    messagesLink = <DesktopNavigationLink 
      url="/messages"
      name="Messages"
      handle="messages" 
      active={props.active} />
    profileLink = <DesktopNavigationLink 
      url="/@andrewbrown" 
      name="Profile"
      handle="profile"
      active={props.active} />
  }

  return (
    <nav>
      <Logo className='logo' />
      <DesktopNavigationLink url="/" 
        name="Home"
        handle="home"
        active={props.active} />
      {notificationsLink}
      {messagesLink}
      {profileLink}
      <DesktopNavigationLink url="/#" 
        name="More" 
        handle="more"
        active={props.active} />
      {button}
      {profile}
    </nav>
  );
}
```

* In `ProfileInfo.js` I added this code ehich defines a function called `signOut` that uses the `Auth` object from the `aws-amplify` library to sign out the currently authenticated user from an AWS Amplify application.
```js
import { Auth } from 'aws-amplify';

const signOut = async () => {
  try {
      await Auth.signOut({ global: true });
      window.location.href = "/"
  } catch (error) {
      console.log('error signing out: ', error);
  }
}
```

* Now I implemented the custom Signin Page, Signout Page and Confirmation Page
[Commit link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/5eb3459ae9392004be509f00156f89b8c930ac9a)
#### Signin Page
```js
import { Auth } from 'aws-amplify';

const [cognitoErrors, setCognitoErrors] = React.useState('');

const onsubmit = async (event) => {
  setCognitoErrors('')
  event.preventDefault();
  try {
    Auth.signIn(username, password)
      .then(user => {
        localStorage.setItem("access_token", user.signInUserSession.accessToken.jwtToken)
        window.location.href = "/"
      })
      .catch(err => { console.log('Error!', err) });
  } catch (error) {
    if (error.code == 'UserNotConfirmedException') {
      window.location.href = "/confirm"
    }
    setCognitoErrors(error.message)
  }
  return false
}

let errors;
if (cognitoErrors){
  errors = <div className='errors'>{cognitoErrors}</div>;
}

// just before submit component
{errors}
```

#### Signout Page
```js
import { Auth } from 'aws-amplify';

const [cognitoErrors, setCognitoErrors] = React.useState('');

const onsubmit = async (event) => {
  event.preventDefault();
  setCognitoErrors('')
  try {
      const { user } = await Auth.signUp({
        username: email,
        password: password,
        attributes: {
            name: name,
            email: email,
            preferred_username: username,
        },
        autoSignIn: { // optional - enables auto sign in after user is confirmed
            enabled: true,
        }
      });
      console.log(user);
      window.location.href = `/confirm?email=${email}`
  } catch (error) {
      console.log(error);
      setCognitoErrors(error.message)
  }
  return false
}

let errors;
if (cognitoErrors){
  errors = <div className='errors'>{cognitoErrors}</div>;
}

//before submit component
{errors}
```
#### Confirmation Page
```js
const resend_code = async (event) => {
  setCognitoErrors('')
  try {
    await Auth.resendSignUp(email);
    console.log('code resent successfully');
    setCodeSent(true)
  } catch (err) {
    // does not return a code
    // does cognito always return english
    // for this to be an okay match?
    console.log(err)
    if (err.message == 'Username cannot be empty'){
      setCognitoErrors("You need to provide an email in order to send Resend Activiation Code")   
    } else if (err.message == "Username/client id combination not found."){
      setCognitoErrors("Email is invalid or cannot be found.")   
    }
  }
}

const onsubmit = async (event) => {
  event.preventDefault();
  setCognitoErrors('')
  try {
    await Auth.confirmSignUp(email, code);
    window.location.href = "/"
  } catch (error) {
    setCognitoErrors(error.message)
  }
  return false
}
```
In the above code I have added the try catch block and used `setCognitoErrors("Email is invalid or cannot be found.") ` to catch the error.
#### Recovery Page
```js
const onsubmit_confirm_code = async (event) => {
  event.preventDefault();
  setCognitoErrors('')
  if (password == passwordAgain){
    Auth.forgotPasswordSubmit(username, code, password)
    .then((data) => setFormState('success'))
    .catch((err) => setCognitoErrors(err.message) );
  } else {
    setCognitoErrors('Passwords do not match')
  }
  return false
}
```
### Proof of Decentralized Authentication

After completing the previous steps, I composed up the docker, and tried signup, signin, and signout. Proofs are shown in the screenshot below.
* If signin with a wrong email or password, it will show "incorrect username or password".

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/581b3fac-e236-4907-9b65-7d8466dabb56)

* If signup with a new user, and verify with the confirmation code was sent to the entered email successfully. After entering the code sent to the email, AWS console of the created user pool showed the user is email verified and confirmed.

![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/b90c2381-2ee1-400e-9365-24d65f133fcb)
![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/3a0dc366-b96d-4808-9497-7c373a2bc22a)

If signin with the newly created user, the home page will show as :
![image](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/assets/92872259/bfbd46c5-7acc-4993-8939-1738f20bc98d)

## JWT Server Side Verify

This step is to serve authenticated API endpoints in Flask Application. Changes can be seen in [Commit Link](https://github.com/ritam-mishra/aws-bootcamp-cruddur-2023/commit/47446257ff6ae623953f257073510e0683bf00a0).

In `frontend-react-js/src/pages/HomeFeedPage.js`, I added `headers` in `const res`. In `frontend-react-js/src/components/ProfileInfo.js`, removed access token in localStorage when signing out.
I decided to keep it simple, small, readable, maintainable and with no complexity. SO, I he chose JWT. Following the steps carefully, I tried to create a user token, Which helped to fetch user data when the user logs in and if user logs out then for that the token was unset.

