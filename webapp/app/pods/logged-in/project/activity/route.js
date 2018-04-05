import {get} from '@ember/object';
import Route from '@ember/routing/route';
import ApolloRoute from 'accent-webapp/mixins/apollo-route';

import projectActivityQuery from 'accent-webapp/queries/project-activity';

export default Route.extend(ApolloRoute, {
  model({activityId}, transition) {
    return this.graphql(projectActivityQuery, {
      props: data => ({
        project: get(data, 'viewer.project'),
        activity: get(data, 'viewer.project.activity')
      }),
      options: {
        fetchPolicy: 'cache-and-network',
        variables: {
          projectId: transition.params['logged-in.project'].projectId,
          activityId
        }
      }
    });
  },

  actions: {
    onRefresh() {
      this.refresh();
    }
  }
});
