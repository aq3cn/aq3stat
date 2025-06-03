const getters = {
  token: state => state.user.token,
  user: state => state.user.user,
  isAdmin: state => state.user.user && state.user.user.group && state.user.user.group.is_admin,
  websites: state => state.website.websites,
  currentWebsite: state => state.website.currentWebsite,
  websiteStats: state => state.website.websiteStats
}

export default getters
