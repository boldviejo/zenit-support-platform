/* global axios */
import ApiClient from './ApiClient';

class SocialCommentsAPI extends ApiClient {
  constructor() {
    super('social_comments', { accountScoped: true });
  }

  get(params) {
    return axios.get(this.url, { params });
  }

  review(id, reviewedDecision) {
    return axios.patch(`${this.url}/${id}`, {
      reviewed_decision: reviewedDecision,
    });
  }

  delete(id) {
    return axios.delete(`${this.url}/${id}`);
  }

  insights(params) {
    return axios.get(`${this.url}/insights`, { params });
  }
}

export default new SocialCommentsAPI();
