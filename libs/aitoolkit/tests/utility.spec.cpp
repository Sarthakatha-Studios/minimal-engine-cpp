#include "doctest.h"

#include "../include/aitoolkit/utility.hpp"

enum class effect {
  a,
  b,
  c,
};

using namespace aitoolkit::utility;
struct blackboard_type {
  effect e;
};

TEST_CASE("utility evaluator") {
  class action_a final : public action<blackboard_type> {
    public:
      virtual float score(const blackboard_type& blackboard) const override {
        return 1.0f;
      }

      virtual void apply(blackboard_type& blackboard) const override {
        blackboard.e = effect::a;
      }
  };

  class action_b final : public action<blackboard_type> {
    public:
      virtual float score(const blackboard_type& blackboard) const override {
        return 2.0f;
      }

      virtual void apply(blackboard_type& blackboard) const override {
        blackboard.e = effect::b;
      }
  };

  class action_c final : public action<blackboard_type> {
    public:
      virtual float score(const blackboard_type& blackboard) const override {
        return 3.0f;
      }

      virtual void apply(blackboard_type& blackboard) const override {
        blackboard.e = effect::c;
      }
  };

  SUBCASE("evaluator runs action with highest score") {
    blackboard_type blackboard;
    auto machine = evaluator<blackboard_type>(
      action_list<blackboard_type>(
        action_a{},
        action_b{},
        action_c{}
      )
    );

    machine.run(blackboard);

    CHECK(blackboard.e == effect::c);
  }
}
