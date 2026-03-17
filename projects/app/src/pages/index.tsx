import { serviceSideProps } from '@/web/common/i18n/utils';
import React, { useEffect } from 'react';
import Loading from '@fastgpt/web/components/common/MyLoading';
import { useRouter } from 'next/router';

const index = () => {
  const router = useRouter();
  useEffect(() => {
    const raw = router.query.autologin;
    const shouldAutoLogin = Array.isArray(raw) ? raw.includes('true') : raw === 'true';

    if (shouldAutoLogin) {
      sessionStorage.setItem('fg_autologin', 'true');
    }

    router.push('/dashboard/agent');
  }, [router]);
  return <Loading></Loading>;
};

export async function getServerSideProps(content: any) {
  return {
    props: {
      ...(await serviceSideProps(content))
    }
  };
}
export default index;
