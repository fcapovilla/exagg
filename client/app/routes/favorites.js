import Ember from 'ember';
import PaginatedItems from '../mixins/paginated-items';

export default Ember.Route.extend(PaginatedItems, {
  model() {
    this.get('filters').selectModel('favorites');

    return Ember.RSVP.hash({
      items: this.store.peekAll('item'),
      first_page: this.loadMore()
    });
  },

  renderTemplate() {
    this.render('item-list');
  },

  actions: {
    loadMore() {
      this.loadMore();
    }
  }
});
