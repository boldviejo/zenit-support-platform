/* global axios */
import ApiClient from './ApiClient';

class MetaAppAPI extends ApiClient {
  constructor() {
    super('meta_app', { accountScoped: true });
  }

  get() {
    return axios.get(this.url);
  }

  update(data) {
    return axios.patch(this.url, { meta_app: data });
  }
}

export default new MetaAppAPI();
