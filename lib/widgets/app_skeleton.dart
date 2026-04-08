import 'package:flutter/material.dart';

class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({
    required this.child,
    super.key,
    this.baseColor = const Color(0xFF1A1A1A),
    this.highlightColor = const Color(0xFF303030),
    this.period = const Duration(milliseconds: 1400),
  });

  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration period;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.period,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final value = _controller.value;

        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.8 + (value * 3.6), 0),
              end: Alignment(-0.8 + (value * 3.6), 0),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.1, 0.5, 0.9],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

class SkeletonBone extends StatelessWidget {
  const SkeletonBone({
    super.key,
    this.width,
    this.height = 14,
    this.radius = 12,
    this.shape = BoxShape.rectangle,
    this.color = const Color(0xFF242424),
    this.margin,
  });

  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;
  final Color color;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : BorderRadius.circular(radius),
      ),
    );
  }
}

class MatchListLoadingSkeleton extends StatelessWidget {
  const MatchListLoadingSkeleton({
    super.key,
    this.cardCount = 3,
    this.showHeader = true,
  });

  final int cardCount;
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showHeader) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF121212),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBone(width: 88, height: 20, radius: 999),
                  SizedBox(height: 16),
                  SkeletonBone(width: 190, height: 18),
                  SizedBox(height: 8),
                  SkeletonBone(width: 250, height: 12),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          ...List.generate(
            cardCount,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: index == cardCount - 1 ? 0 : 12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF131313),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.white.withOpacity(0.06)),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: Column(
                        children: [
                          SkeletonBone(width: 24, height: 12, radius: 999),
                          SizedBox(height: 10),
                          SkeletonBone(width: 2, height: 34, radius: 999),
                        ],
                      ),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        children: [
                          _SkeletonTeamRow(),
                          SizedBox(height: 12),
                          _SkeletonTeamRow(),
                        ],
                      ),
                    ),
                    SizedBox(width: 10),
                    SkeletonBone(width: 20, height: 20, radius: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NewsFeedLoadingSkeleton extends StatelessWidget {
  const NewsFeedLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: const Column(
        children: [
          _SkeletonPosterCard(),
          SizedBox(height: 14),
          _SkeletonSplitCard(),
          SizedBox(height: 14),
          _SkeletonPosterCard(),
        ],
      ),
    );
  }
}

class SearchResultsLoadingSkeleton extends StatelessWidget {
  const SearchResultsLoadingSkeleton({
    super.key,
    this.itemCount = 5,
  });

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index == itemCount - 1 ? 0 : 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF141414),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: const Row(
                children: [
                  SkeletonBone(width: 52, height: 52, radius: 14),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBone(width: 160, height: 14),
                        SizedBox(height: 8),
                        SkeletonBone(width: double.infinity, height: 11),
                        SizedBox(height: 6),
                        SkeletonBone(width: 130, height: 11),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SkeletonBone(width: 54, height: 22, radius: 999),
                      SizedBox(height: 12),
                      SkeletonBone(width: 18, height: 18, radius: 9),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NewsDetailLoadingSkeleton extends StatelessWidget {
  const NewsDetailLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Container(
            height: 280,
            color: const Color(0xFF171717),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SkeletonBone(width: 92, height: 30, radius: 999),
                const SizedBox(height: 18),
                const SkeletonBone(width: double.infinity, height: 26),
                const SizedBox(height: 10),
                const SkeletonBone(width: 250, height: 26),
                const SizedBox(height: 14),
                const SkeletonBone(width: 180, height: 12),
                const SizedBox(height: 22),
                const SkeletonBone(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                const SkeletonBone(width: double.infinity, height: 14),
                const SizedBox(height: 8),
                const SkeletonBone(width: 220, height: 14),
                const SizedBox(height: 22),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBone(width: double.infinity, height: 12),
                      SizedBox(height: 10),
                      SkeletonBone(width: double.infinity, height: 12),
                      SizedBox(height: 10),
                      SkeletonBone(width: double.infinity, height: 12),
                      SizedBox(height: 10),
                      SkeletonBone(width: 230, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MatchDetailLoadingSkeleton extends StatelessWidget {
  const MatchDetailLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Column(
              children: [
                SkeletonBone(width: 120, height: 14),
                SizedBox(height: 8),
                SkeletonBone(width: 80, height: 11),
                SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(child: _SkeletonTeamColumn()),
                    SizedBox(width: 20),
                    Column(
                      children: [
                        SkeletonBone(width: 48, height: 14, radius: 999),
                        SizedBox(height: 12),
                        SkeletonBone(width: 58, height: 24),
                      ],
                    ),
                    SizedBox(width: 20),
                    Expanded(child: _SkeletonTeamColumn()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF111111),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBone(width: 130, height: 16),
                  SizedBox(height: 18),
                  SkeletonBone(width: double.infinity, height: 12),
                  SizedBox(height: 12),
                  SkeletonBone(width: double.infinity, height: 12),
                  SizedBox(height: 12),
                  SkeletonBone(width: 200, height: 12),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFF171717),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonPosterCard extends StatelessWidget {
  const _SkeletonPosterCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1D),
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 250, color: const Color(0xFF191919)),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonBone(width: 84, height: 24, radius: 999),
                SizedBox(height: 14),
                SkeletonBone(width: double.infinity, height: 16),
                SizedBox(height: 8),
                SkeletonBone(width: 220, height: 16),
                SizedBox(height: 12),
                SkeletonBone(width: double.infinity, height: 11),
                SizedBox(height: 6),
                SkeletonBone(width: 170, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonSplitCard extends StatelessWidget {
  const _SkeletonSplitCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      decoration: BoxDecoration(
        color: const Color(0xFF232323),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 150,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF191919),
              borderRadius: BorderRadius.horizontal(left: Radius.circular(22)),
            ),
          ),
          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBone(width: double.infinity, height: 14),
                  SizedBox(height: 8),
                  SkeletonBone(width: 170, height: 14),
                  Spacer(),
                  SkeletonBone(width: 140, height: 12),
                  SizedBox(height: 10),
                  SkeletonBone(width: 110, height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonTeamRow extends StatelessWidget {
  const _SkeletonTeamRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SkeletonBone(width: 26, height: 26, shape: BoxShape.circle),
        SizedBox(width: 8),
        Expanded(child: SkeletonBone(width: double.infinity, height: 12)),
        SizedBox(width: 8),
        SkeletonBone(width: 28, height: 14),
      ],
    );
  }
}

class _SkeletonTeamColumn extends StatelessWidget {
  const _SkeletonTeamColumn();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SkeletonBone(width: 64, height: 64, shape: BoxShape.circle),
        SizedBox(height: 12),
        SkeletonBone(width: 100, height: 12),
        SizedBox(height: 8),
        SkeletonBone(width: 42, height: 26),
      ],
    );
  }
}
