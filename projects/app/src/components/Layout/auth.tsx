import { useRouter } from 'next/router';
import { useUserStore } from '@/web/support/user/useUserStore';
import { useQuery } from '@tanstack/react-query';
import { useTranslation } from 'next-i18next';
import { useToast } from '@fastgpt/web/hooks/useToast';
import type { LangEnum } from '@fastgpt/global/common/i18n/type';

const unAuthPage: { [key: string]: boolean } = {
  '/': true,
  '/login': true,
  '/login/provider': true,
  '/login/fastlogin': true,
  '/login/sso': true,
  '/appStore': true,
  '/chat': true,
  '/chat/share': true,
  '/tools/price': true,
  '/price': true
};

const Auth = ({ children }: { children: JSX.Element | React.ReactNode }) => {
  const { t, i18n } = useTranslation();
  const router = useRouter();
  const { toast } = useToast();
  const { userInfo, initUserInfo, autoLogin } = useUserStore();

  useQuery(
    ['auth-init', router.pathname, router.isReady, router.query.autologin],
    async () => {
      if (!router.isReady) return null;

      if (unAuthPage[router.pathname] === true) return null;
      if (userInfo) return userInfo;

      const raw = router.query.autologin;
      const fromQuery = Array.isArray(raw) ? raw.includes('true') : raw === 'true';
      const fromStorage =
        typeof window !== 'undefined' && sessionStorage.getItem('fg_autologin') === 'true';
      const shouldAutoLogin = fromQuery || fromStorage;

      if (shouldAutoLogin) {
        try {
          const user = await autoLogin({ language: i18n.language });

          // 清理 autologin 参数，避免刷新后重复自动登录
          const { autologin, ...restQuery } = router.query;
          await router.replace({ pathname: router.pathname, query: restQuery }, undefined, {
            shallow: true
          });

          return user;
        } catch {
          // 自动登录失败则走原有流程
          return initUserInfo();
        }
      }

      return initUserInfo();
    },
    {
      enabled: router.isReady,
      refetchInterval: 10 * 60 * 1000,
      onError() {
        toast({
          status: 'warning',
          title: t('common:support.user.Need to login')
        });
      }
    }
  );

  return !!userInfo || unAuthPage[router.pathname] === true ? children : null;
};

export default Auth;
