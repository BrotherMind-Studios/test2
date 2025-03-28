// pages/_document.tsx
/* eslint-disable @typescript-eslint/no-require-imports */
const newrelic = require("newrelic");
import Document, {
 Html,
 Head,
 Main,
 NextScript,
} from "next/document";
 

interface MyDocumentProps {
  browserTimingHeader: string;
}

class MyDocument extends Document<MyDocumentProps> {
  /* eslint-disable @typescript-eslint/no-explicit-any */
  static async getInitialProps(ctx: any) {
   const initialProps = await Document.getInitialProps(ctx);
 
   const browserTimingHeader = newrelic.getBrowserTimingHeader({
     hasToRemoveScriptWrapper: true,
   });
 
   return {
     ...initialProps,
     browserTimingHeader,
   };
 }
 
 render() {
   return (
     <Html>
       <Head>
         <script
           type="text/javascript"
           dangerouslySetInnerHTML={{ __html: this.props.browserTimingHeader }}
         />
       </Head>
       <body>
         <Main />
         <NextScript />
       </body>
     </Html>
   );
 }
}
 
export default MyDocument;